extends CharacterBody3D

@export var speed = 5.0;
@export var jump_force = 4.5;
@export var sensitivity = 0.2;
@export var up_limit = 80;
@export var down_limit = -60;

@export_category("Leaning (Peeking)")
@export var lean_angle: float = 15.0; ## Inclinação da cabeça em graus
@export var lean_offset_x: float = 0.4; ## Distância que a cabeça se move para o lado
@export var lean_speed: float = 8.0;

var _target_lean_angle: float = 0.0;
var _target_lean_offset: float = 0.0;

@onready var head = $Head;
@onready var vertical = $Head/Vertical;
@onready var weapon = $Head/Vertical/Camera3D/SwayPivot/AimPivot/ArmaModel;

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

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

	var input_dir := Input.get_vector("left", "right", "up", "down");
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized();
	if direction:
		velocity.x = direction.x * speed;
		velocity.z = direction.z * speed;
	else:
		velocity.x = move_toward(velocity.x, 0, speed);
		velocity.z = move_toward(velocity.z, 0, speed);

	move_and_slide();
	_handle_lean(delta)

func _handle_lean(delta: float) -> void:
	if Input.is_physical_key_pressed(KEY_Q):
		_target_lean_angle = lean_angle
		_target_lean_offset = -lean_offset_x
	elif Input.is_physical_key_pressed(KEY_E) or Input.is_physical_key_pressed(KEY_R):
		_target_lean_angle = -lean_angle
		_target_lean_offset = lean_offset_x
	else:
		_target_lean_angle = 0.0
		_target_lean_offset = 0.0
		
	head.rotation.z = lerp_angle(head.rotation.z, deg_to_rad(_target_lean_angle), lean_speed * delta)
	head.position.x = lerp(head.position.x, _target_lean_offset, lean_speed * delta)
