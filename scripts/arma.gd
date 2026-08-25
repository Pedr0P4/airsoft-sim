extends Node3D

@export var bullet_scene: PackedScene;
@onready var muzzle: Marker3D = $ArmaModel/SaidaBala;
@onready var hopup_label: Label = get_tree().current_scene.find_child("HopupLabel", true, false)

var current_hopup_rpm: float = 6000.0
var hopup_step: float = 1000.0
var min_hopup: float = 0.0
var max_hopup: float = 20000.0

func _ready() -> void:
	update_hopup_label()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		shoot()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			change_hopup(hopup_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			change_hopup(-hopup_step)

func change_hopup(amount: float) -> void:
	current_hopup_rpm = clamp(current_hopup_rpm + amount, min_hopup, max_hopup)
	update_hopup_label()

func update_hopup_label() -> void:
	if hopup_label:
		hopup_label.text = "Hopup: %d RPM" % current_hopup_rpm

func shoot() -> void:
	print("atirado");
	var bullet = bullet_scene.instantiate();
	var scene_root = get_tree().current_scene if get_tree().current_scene else get_tree().root
	scene_root.add_child(bullet);
	if "backspin_rpm" in bullet:
		bullet.backspin_rpm = current_hopup_rpm
	if bullet.has_method("fire"):
		bullet.fire(muzzle.global_transform);
