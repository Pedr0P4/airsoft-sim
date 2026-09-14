extends Node3D
class_name WeaponController

@export_category("Weapon Sway")
@export var sway_amount: float = 0.005
@export var max_sway: float = 0.05
@export var sway_speed: float = 10.0

@export_category("Aim Down Sights (ADS)")
@export var aim_position: Vector3 = Vector3(-0.27, 0.1, 0.274)
@export var aim_speed: float = 12.0

# Referência para o nó filho AimPivot (que guardará a arma)
@onready var aim_pivot: Node3D = $AimPivot

var _mouse_movement: Vector2 = Vector2.ZERO
var _is_aiming: bool = false
var _bob_time: float = 0.0

var _is_reloading: bool = false
var _reload_time: float = 0.0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_mouse_movement += event.relative
	if event.is_action_pressed("reload") and not _is_reloading:
		_is_reloading = true
		_reload_time = 0.0

func _process(delta: float) -> void:
	_handle_sway(delta)
	_handle_aim_and_bob(delta)
	_handle_reload_anim(delta)

func _handle_sway(delta: float) -> void:
	var target_sway_x: float = clamp(-_mouse_movement.y * sway_amount, -max_sway, max_sway)
	var target_sway_y: float = clamp(-_mouse_movement.x * sway_amount, -max_sway, max_sway)
	
	rotation.x = lerp(rotation.x, target_sway_x, sway_speed * delta)
	rotation.y = lerp(rotation.y, target_sway_y, sway_speed * delta)
	
	_mouse_movement = _mouse_movement.lerp(Vector2.ZERO, sway_speed * delta)

func _handle_aim_and_bob(delta: float) -> void:
	_is_aiming = Input.is_action_pressed("aim")
	
	var target_position: Vector3 = aim_position if _is_aiming else Vector3.ZERO
	
	# Add run bobbing if not aiming
	var is_running = Input.is_action_pressed("run")
	var input_dir = Input.get_vector("left", "right", "up", "down")
	if is_running and not _is_aiming and input_dir.length() > 0:
		_bob_time += delta * 15.0
		target_position.y += sin(_bob_time) * 0.05
		target_position.x += cos(_bob_time * 0.5) * 0.05
	else:
		_bob_time = 0.0
			
	aim_pivot.position = aim_pivot.position.lerp(target_position, aim_speed * delta)

func _handle_reload_anim(delta: float) -> void:
	if _is_reloading:
		_reload_time += delta
		if _reload_time < 0.2:
			aim_pivot.rotation.x = lerp(aim_pivot.rotation.x, deg_to_rad(-60.0), delta * 15.0)
		elif _reload_time < 0.6:
			pass
		else:
			aim_pivot.rotation.x = lerp(aim_pivot.rotation.x, 0.0, delta * 10.0)
			if aim_pivot.rotation.x > deg_to_rad(-1.0):
				aim_pivot.rotation.x = 0.0
				_is_reloading = false
