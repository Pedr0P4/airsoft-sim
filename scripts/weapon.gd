class_name Weapon
extends Node3D

@export var bullet_scene: PackedScene;
@export var max_ammo: int;
@onready var muzzle: Marker3D = $RifleModel/SaidaBala;

var hopup_label: Label;
var ammo_label: Label;
var firemode_label: Label;

enum FireMode { SEMI, AUTO }
var current_fire_mode: FireMode = FireMode.SEMI

@export_category("Fire Settings")
@export var motor_rpm: float = 8100.0
@export var motor_rotations_per_shot: float = 30.0
var fire_interval: float = 0.0
var time_since_last_shot: float = 0.0

var current_hopup_rpm: float = 6000.0;
var hopup_step: float = 500.0;
var min_hopup: float = 0.0;
var max_hopup: float = 20000.0;
var current_ammo: int = 0;

func _ready() -> void:
	current_ammo = max_ammo;
	update_hopup_label();
	update_ammo_label();
	update_fire_interval();
	update_firemode_label();

func update_fire_interval() -> void:
	var rof = motor_rpm / (60.0 * motor_rotations_per_shot)
	if rof > 0.0:
		fire_interval = 1.0 / rof
	else:
		fire_interval = 0.1

func _process(delta: float) -> void:
	time_since_last_shot += delta
	
	if current_fire_mode == FireMode.AUTO:
		if Input.is_action_pressed("shoot") and current_ammo > 0 and time_since_last_shot >= fire_interval:
			shoot()
			time_since_last_shot = 0.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fire_mode"):
		if current_fire_mode == FireMode.SEMI:
			current_fire_mode = FireMode.AUTO
		else:
			current_fire_mode = FireMode.SEMI
		update_firemode_label()
		print("Modo de tiro alterado para: ", "AUTO" if current_fire_mode == FireMode.AUTO else "SEMI")

	if current_fire_mode == FireMode.SEMI:
		if event.is_action_pressed("shoot") and current_ammo > 0 and time_since_last_shot >= fire_interval:
			shoot()
			time_since_last_shot = 0.0

	if event.is_action_pressed("reload"):
		current_ammo = max_ammo;
		update_ammo_label();
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			change_hopup(hopup_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			change_hopup(-hopup_step)

func update_firemode_label() -> void:
	if firemode_label:
		firemode_label.text = "Modo: AUTO" if current_fire_mode == FireMode.AUTO else "Modo: SEMI"


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
	var bullet: Bullet = bullet_scene.instantiate();
	var scene_root = get_tree().current_scene if get_tree().current_scene else get_tree().root
	scene_root.add_child(bullet);
	inc_ammo(-1);
	if "backspin_rpm" in bullet:
		bullet.backspin_rpm = current_hopup_rpm
	if bullet.has_method("fire"):
		bullet.fire(muzzle.global_transform);
	
	bullet.bonk_something.connect(_on_bullet_hit)

func _on_bullet_hit() -> void:
	var acerto_scene = preload("res://scenes/acerto.tscn")
	var acerto = acerto_scene.instantiate()
	if hopup_label and hopup_label.get_parent():
		hopup_label.get_parent().add_child(acerto)
		await get_tree().create_timer(0.2).timeout
		if is_instance_valid(acerto):
			acerto.queue_free()

func inc_ammo(amount: int) -> void:
	current_ammo += amount;
	update_ammo_label();
