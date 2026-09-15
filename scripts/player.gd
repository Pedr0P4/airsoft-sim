extends CharacterBody3D

@export_category("debug")
@export var begin_weapon: WeaponResource;

@export_category("Player Settings")
@export var speed = 5.0;
@export var run_speed = 8.0;
@export var jump_force = 4.5;
@export var sensitivity = 0.2;
@export var up_limit = 80;
@export var down_limit = -60;

@export_category("Leaning (Peeking)")
@export var lean_angle: float = 15.0;
@export var lean_offset_x: float = 0.4;
@export var lean_speed: float = 8.0;

var _target_lean_angle: float = 0.0;
var _target_lean_offset: float = 0.0;

@onready var head = $Head
@onready var vertical = $Head/Vertical
@onready var weapon_manager = $WeaponManager
@onready var score_label = $CanvasLayer/HUD/ScoreLabel

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	if begin_weapon:
		weapon_manager.coletar_arma(begin_weapon);
	
	if has_node("/root/Global"):
		var global = get_node("/root/Global")
		global.score_changed.connect(_on_score_changed)
		global.points_received.connect(_on_points_received)
		global.time_changed.connect(_on_time_changed)
		_on_score_changed(global.score)
		
		# Create time label dynamically
		var time_label = Label.new()
		time_label.name = "TimeLabel"
		time_label.text = "Tempo: ∞"
		time_label.add_theme_font_size_override("font_size", 32)
		time_label.add_theme_color_override("font_color", Color(1, 1, 1))
		time_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		time_label.add_theme_constant_override("outline_size", 4)
		$CanvasLayer/HUD.add_child(time_label)
		time_label.position = Vector2(20, 70) # Below score label

		if Global.current_game_mode == Global.GameMode.TREINO:
			var back_label = Label.new()
			back_label.text = "[BACKSPACE] Voltar ao Menu"
			back_label.add_theme_font_size_override("font_size", 24)
			back_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
			back_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
			back_label.add_theme_constant_override("outline_size", 4)
			$CanvasLayer/HUD.add_child(back_label)
			back_label.position = Vector2(20, 110)

func _on_time_changed(time_left: int) -> void:
	if $CanvasLayer/HUD.has_node("TimeLabel"):
		$CanvasLayer/HUD.get_node("TimeLabel").text = "Tempo: " + str(time_left) + "s"

func _on_score_changed(new_score: int) -> void:
	if score_label:
		score_label.text = "Score: " + str(new_score)

func _on_points_received(points: int) -> void:
	var hud = $CanvasLayer/HUD
	if not hud: return
	
	var label = Label.new()
	if points >= 0:
		label.text = "+" + str(points)
		label.add_theme_color_override("font_color", Color(1, 1, 0, 1))
	else:
		label.text = str(points)
		label.add_theme_color_override("font_color", Color(1, 0, 0, 1))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 4)
	label.add_theme_font_size_override("font_size", 24)
	
	hud.add_child(label)
	
	var screen_size = get_viewport().get_visible_rect().size
	var random_offset_x = randf_range(-50, 50)
	var random_offset_y = randf_range(-30, 30)
	label.position = Vector2(screen_size.x / 2.0 + random_offset_x, screen_size.y / 2.0 + random_offset_y)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 100, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(label.queue_free)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		vertical.rotate_x(deg_to_rad(-event.relative.y * sensitivity))
		vertical.rotation.x = clamp(
			vertical.rotation.x,
			deg_to_rad(down_limit),
			deg_to_rad(up_limit)
		);

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta;

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force;
		
	var current_speed = run_speed if Input.is_action_pressed("run") else speed

	var input_dir := Input.get_vector("left", "right", "up", "down");
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized();
	if direction:
		velocity.x = direction.x * current_speed;
		velocity.z = direction.z * current_speed;
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed);
		velocity.z = move_toward(velocity.z, 0, current_speed);

	move_and_slide();
	_handle_lean(delta)

func _handle_lean(delta: float) -> void:
	if Input.is_physical_key_pressed(KEY_Q):
		_target_lean_angle = lean_angle
		_target_lean_offset = -lean_offset_x
	elif Input.is_physical_key_pressed(KEY_E):
		_target_lean_angle = -lean_angle
		_target_lean_offset = lean_offset_x
	else:
		_target_lean_angle = 0.0
		_target_lean_offset = 0.0
		
	head.rotation.z = lerp_angle(head.rotation.z, deg_to_rad(_target_lean_angle), lean_speed * delta)
	head.position.x = lerp(head.position.x, _target_lean_offset, lean_speed * delta)
