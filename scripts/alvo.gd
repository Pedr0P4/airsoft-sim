class_name Target
extends StaticBody3D

@export var life: int = 1
var is_dead: bool = false

@onready var head_area = get_node_or_null("HeadArea")
@onready var body_area = get_node_or_null("BodyArea")

func _ready() -> void:
	pass

func deal_damage(damage: int) -> void:
	if is_dead:
		return
		
	var hit_score = 100 if damage == 5 else 10
	
	life -= damage
	if life <= 0:
		is_dead = true
		var kill_score = 1000 if damage == 5 else 500
		die(hit_score + kill_score)
	else:
		Global.add_score(hit_score)

func die(points: int) -> void:
	Global.add_score(points)
	queue_free()
