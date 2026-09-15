class_name MagazineResource
extends Resource

@export var type: Enums.WeaponType
@export var capacity: int = 30
@export var current_ammo: int = 30
@export var mass_kg: float = 0.00025 # 0.25g

func is_empty() -> bool:
	return current_ammo <= 0

func use_ammo() -> bool:
	if current_ammo > 0:
		current_ammo -= 1
		return true
	return false
