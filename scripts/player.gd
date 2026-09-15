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
var _target_lean_offset: float = 0.0

var magazine_inventory: Dictionary = {
	Enums.WeaponType.SHOTGUN: [],
	Enums.WeaponType.RIFLE: [],
	Enums.WeaponType.SNIPER: [],
	Enums.WeaponType.PISTOLGLOCK: []
}

var max_mags_per_type: int = 5
;

@onready var head = $Head
@onready var vertical = $Head/Vertical
@onready var weapon_manager = $WeaponManager
@onready var score_label = $CanvasLayer/HUD/ScoreLabel

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	if begin_weapon:
		weapon_manager.coletar_arma(begin_weapon);
	
	_setup_magazines_ui()
	var interact_ray = RayCast3D.new()
	interact_ray.name = "InteractRay"
	interact_ray.target_position = Vector3(0, 0, -3.0)
	interact_ray.collide_with_areas = true
	interact_ray.collide_with_bodies = false
	var cam = vertical.get_node_or_null("Camera3D")
	if cam:
		cam.add_child(interact_ray)
	else:
		vertical.add_child(interact_ray)
		


	
	if has_node("/root/Global"):
		var global = get_node("/root/Global")
		global.score_changed.connect(_on_score_changed)
		global.points_received.connect(_on_points_received)
		global.time_changed.connect(_on_time_changed)
		global.feedback_received.connect(_on_feedback_received)
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

func _on_feedback_received(msg: String) -> void:
	var hud = $CanvasLayer/HUD
	if not hud: return
	var lbl = Label.new()
	lbl.text = msg
	lbl.add_theme_color_override("font_color", Color(1, 0, 0))
	lbl.add_theme_font_size_override("font_size", 32)
	lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	lbl.add_theme_constant_override("outline_size", 4)
	hud.add_child(lbl)
	
	var screen_size = get_viewport().get_visible_rect().size
	lbl.position = Vector2(screen_size.x / 2.0 - 100, screen_size.y / 2.0 + 100)
	var tw = create_tween()
	tw.tween_property(lbl, "modulate:a", 0.0, 2.0)
	tw.tween_callback(lbl.queue_free)

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
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_E:
			_try_interact()
		elif event.physical_keycode == KEY_R:
			_reload_weapon()

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

func _try_interact():
	var ray = vertical.get_node_or_null("Camera3D/InteractRay")
	if not ray: ray = vertical.get_node_or_null("InteractRay")
	if ray and ray.is_colliding():
		var collider = ray.get_collider()
		if collider.has_method('get_magazine'):
			var mag = collider.get_magazine()
			var act_wep = weapon_manager.active_weapon
			if act_wep:
				var type = mag.type
				if magazine_inventory[type].size() < max_mags_per_type:
					magazine_inventory[type].append(mag)
					collider.queue_free()
					
					# Tenta equipar automaticamente se estiver vazio
					if act_wep.weapon_type == type and act_wep.equipped_magazine == null:
						_reload_weapon()
					else:
						update_mags_ui()
				else:
					Global.emit_feedback("Mochila cheia para este tipo!")

func _setup_magazines_ui():
	var hud = $CanvasLayer/HUD
	
	# Container for the magazine bars
	var mags_container = HBoxContainer.new()
	mags_container.name = "MagsContainer"
	mags_container.position = Vector2(20, 190)
	mags_container.add_theme_constant_override("separation", 10)
	hud.add_child(mags_container)
	
	# Weapon icon
	var icon_rect = TextureRect.new()
	icon_rect.name = "WeaponIcon"
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.custom_minimum_size = Vector2(64, 64)
	icon_rect.position = Vector2(20, 270)
	hud.add_child(icon_rect)

func _reload_weapon():
	var act_wep = weapon_manager.active_weapon
	if not act_wep: return
	
	var type = act_wep.weapon_type
	var inv = magazine_inventory[type]
	
	if inv.size() == 0:
		Global.emit_feedback("Sem carregadores reservas!")
		return
		
	var current_mag = act_wep.equipped_magazine
	
	# Se tem carregador equipado e tem bala, guarda no inventario
	if current_mag != null:
		if current_mag.current_ammo > 0:
			inv.append(current_mag)
		# Se estiver vazio, ele eh descartado (apenas não damos append)
		
	# Pega o primeiro da fila (poderia ser o mais cheio, mas vamos pegar FIFO)
	var new_mag = inv.pop_front()
	act_wep.equipped_magazine = new_mag
	
	if act_wep.has_method("update_ammo_label"):
		act_wep.update_ammo_label()
	if act_wep.has_method("update_mass_label"):
		act_wep.update_mass_label()
		
	update_mags_ui()

func update_mags_ui():
	var hud = $CanvasLayer/HUD
	var container = hud.get_node_or_null("MagsContainer")
	var icon_rect = hud.get_node_or_null("WeaponIcon")
	if not container or not icon_rect: return
	
	# Clear children
	for child in container.get_children():
		child.queue_free()
		
	var act_wep = weapon_manager.active_weapon
	if not act_wep: return
	
	var type = act_wep.weapon_type
	var inv = magazine_inventory[type]
	
	var color = Color(1, 1, 1)
	var icon_path = ""
	
	if type == Enums.WeaponType.SHOTGUN:
		color = Color(0.8, 0.2, 0.2)
		icon_path = "res://resources/icons/shotgun.svg"
	elif type == Enums.WeaponType.RIFLE:
		color = Color(0.2, 0.4, 0.8)
		icon_path = "res://resources/icons/rifle.svg"
	elif type == Enums.WeaponType.SNIPER:
		color = Color(0.2, 0.8, 0.2)
		icon_path = "res://resources/icons/sniper.svg"
	elif type == Enums.WeaponType.PISTOLGLOCK:
		color = Color(0.8, 0.4, 0.8)
		icon_path = "res://resources/icons/glock.svg"
		
	if icon_path != "":
		icon_rect.texture = load(icon_path)
		icon_rect.modulate = color
		
	# Mostramos as barrinhas dos reservas
	for mag in inv:
		var progress = ProgressBar.new()
		progress.custom_minimum_size = Vector2(20, 60)
		progress.fill_mode = ProgressBar.FILL_BOTTOM_TO_TOP
		progress.show_percentage = false
		progress.max_value = mag.capacity
		progress.value = mag.current_ammo
		
		# Aplica cor usando StyleBox
		var style_bg = StyleBoxFlat.new()
		style_bg.bg_color = Color(0.2, 0.2, 0.2, 0.8)
		
		var style_fg = StyleBoxFlat.new()
		style_fg.bg_color = color
		
		progress.add_theme_stylebox_override("background", style_bg)
		progress.add_theme_stylebox_override("fill", style_fg)
		
		container.add_child(progress)
