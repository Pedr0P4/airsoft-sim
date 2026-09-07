extends Node3D

@export var bullet_scene: PackedScene;
@export var max_ammo: int;
@export var hopup_label: Label;
@export var ammo_label: Label;
@onready var muzzle: Marker3D = $ArmaModel/SaidaBala;

var current_hopup_rpm: float = 6000.0;
var hopup_step: float = 500.0;
var min_hopup: float = 0.0;
var max_hopup: float = 20000.0;
var current_ammo: int = 0;

func _ready() -> void:
	current_ammo = max_ammo;
	update_hopup_label();
	update_ammo_label();

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot") and current_ammo > 0:
		shoot();
	if event.is_action_pressed("reload"):
		current_ammo = max_ammo;
		update_ammo_label();
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

func update_ammo_label() -> void:
	if ammo_label:
		ammo_label.text = str(current_ammo) + " / " + str(max_ammo);

func shoot() -> void:
	var bullet = bullet_scene.instantiate();
	var scene_root = get_tree().current_scene if get_tree().current_scene else get_tree().root
	scene_root.add_child(bullet);
	inc_ammo(-1);
	if "backspin_rpm" in bullet:
		bullet.backspin_rpm = current_hopup_rpm
	if bullet.has_method("fire"):
		bullet.fire(muzzle.global_transform);

func inc_ammo(amount: int) -> void:
	current_ammo += amount;
	update_ammo_label();
