class_name MagazinePickup
extends Area3D

@export var magazine_data: MagazineResource

func _ready() -> void:
	# Ensure it behaves as an area to interact with
	pass

# Called when player interacts
func get_magazine() -> MagazineResource:
	return magazine_data
