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

func _input(event: InputEvent) -> void:
	# Captura qualquer movimento do mouse
	if event is InputEventMouseMotion:
		_mouse_movement += event.relative

func _process(delta: float) -> void:
	_handle_sway(delta)
	_handle_aim(delta)

func _handle_sway(delta: float) -> void:
	# Calcula a rotação alvo invertendo o movimento do mouse para dar peso à arma
	var target_sway_x: float = clamp(-_mouse_movement.y * sway_amount, -max_sway, max_sway)
	var target_sway_y: float = clamp(-_mouse_movement.x * sway_amount, -max_sway, max_sway)
	
	# Aplica lerp na rotação X (cima/baixo) e Y (esquerda/direita) do SwayPivot
	rotation.x = lerp(rotation.x, target_sway_x, sway_speed * delta)
	rotation.y = lerp(rotation.y, target_sway_y, sway_speed * delta)
	
	# Drena o movimento acumulado de volta a zero suavemente
	_mouse_movement = _mouse_movement.lerp(Vector2.ZERO, sway_speed * delta)

func _handle_aim(delta: float) -> void:
	# Verifica a ação 'aim'
	_is_aiming = Input.is_action_pressed("aim")
	
	var target_position: Vector3 = aim_position if _is_aiming else Vector3.ZERO
			
	# 1. Posição de Mira (Move o AimPivot)
	aim_pivot.position = aim_pivot.position.lerp(target_position, aim_speed * delta)
