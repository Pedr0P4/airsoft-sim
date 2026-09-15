class_name Weapon
extends Node3D

@export var bullet_scene: PackedScene;
@export var max_ammo: int;
@export var muzzle_path: NodePath
@onready var muzzle: Marker3D = get_node_or_null(muzzle_path) as Marker3D

var hopup_label: Label;
var ammo_label: Label;
var firemode_label: Label;

enum FireMode { SEMI, AUTO }
var current_fire_mode: FireMode = FireMode.SEMI

@export_category("Aiming")
@export var can_aim: bool = false
@export var aim_fov: float = 20.0
@export var use_scope: bool = false
@export var aim_speed: float = 10.0
@export var aim_position: Vector3 = Vector3(0, 0, 0.1)

var is_aiming: bool = false
var default_position: Vector3
var default_fov: float = 75.0
var scope_hud: Control = null
var camera: Camera3D = null

@export_category("Fire Settings")
@export var can_auto: bool = false
@export var motor_rpm: float = 8100.0
@export var motor_rotations_per_shot: float = 30.0
var fire_interval: float = 0.0
var time_since_last_shot: float = 0.0

@export_category("Ballistics")
@export var joules: float = 1.49
@export var mass_kg: float = 0.0002
@export var bullets_per_shot: int = 1
@export var spread_angle: float = 0.0

var current_hopup_rpm: float = 6000.0;
var hopup_step: float = 500.0;
var min_hopup: float = 0.0;
var max_hopup: float = 20000.0;
var current_ammo: int = 0;

func _ready() -> void:
	if muzzle == null:
		push_warning("Muzzle not set for weapon " + name + ". Attempting to find SaidaBala in children.")
		muzzle = find_child("SaidaBala", true, false) as Marker3D
	
	default_position = position
	if use_scope:
		_create_scope_hud()
	
	current_ammo = max_ammo;
	update_hopup_label();
	update_ammo_label();
	update_fire_interval();
	update_firemode_label();

func _create_scope_hud() -> void:
	var canvas = CanvasLayer.new()
	canvas.name = "ScopeCanvas"
	canvas.layer = 10
	add_child(canvas)
	
	scope_hud = Control.new()
	scope_hud.set_script(preload("res://scripts/scope_hud.gd"))
	scope_hud.hide()
	canvas.add_child(scope_hud)

func update_fire_interval() -> void:
	var rof = motor_rpm / (60.0 * motor_rotations_per_shot)
	if rof > 0.0:
		fire_interval = 1.0 / rof
	else:
		fire_interval = 0.1

func _process(delta: float) -> void:
	time_since_last_shot += delta
	
	if can_aim:
		if not camera:
			camera = get_viewport().get_camera_3d()
		
		if camera:
			var target_pos = aim_position if is_aiming else default_position
			var target_fov = aim_fov if is_aiming else default_fov
			
			position = position.lerp(target_pos, aim_speed * delta)
			camera.fov = lerp(camera.fov, target_fov, aim_speed * delta)
			
			if use_scope and scope_hud:
				if is_aiming and abs(camera.fov - aim_fov) < 5.0:
					scope_hud.show()
					for child in get_children():
						if child is Node3D and child.name != "ScopeCanvas":
							child.hide()
				else:
					scope_hud.hide()
					for child in get_children():
						if child is Node3D and child.name != "ScopeCanvas":
							child.show()
	
	if current_fire_mode == FireMode.AUTO:
		if Input.is_action_pressed("shoot") and current_ammo > 0 and time_since_last_shot >= fire_interval:
			shoot()
			time_since_last_shot = 0.0

func _input(event: InputEvent) -> void:
	if can_aim:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				is_aiming = true
			else:
				is_aiming = false

	if event.is_action_pressed("toggle_fire_mode"):
		if can_auto:
			if current_fire_mode == FireMode.SEMI:
				current_fire_mode = FireMode.AUTO
			else:
				current_fire_mode = FireMode.SEMI
			update_firemode_label()
			print("Modo de tiro alterado para: ", "AUTO" if current_fire_mode == FireMode.AUTO else "SEMI")
		else:
			print("Esta arma não possui modo automático.")

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
	inc_ammo(-1);
	for i in range(bullets_per_shot):
		var bullet: Bullet = bullet_scene.instantiate();
		var scene_root = get_tree().current_scene if get_tree().current_scene else get_tree().root
		scene_root.add_child(bullet);
		
		if "joules" in bullet:
			bullet.joules = joules
		if "mass_kg" in bullet:
			bullet.mass_kg = mass_kg
		if "backspin_rpm" in bullet:
			bullet.backspin_rpm = current_hopup_rpm
			
		var spawn_transform = muzzle.global_transform
		
		# Alinha o tiro exatamente com o centro da tela (mira)
		if not camera:
			camera = get_viewport().get_camera_3d()
		if camera:
			var viewport_size = get_viewport().get_visible_rect().size
			var screen_center = viewport_size / 2.0
			var from = camera.project_ray_origin(screen_center)
			var to = from + camera.project_ray_normal(screen_center) * 1000.0
			
			var space_state = get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(from, to)
			query.collide_with_areas = true
			query.collide_with_bodies = true
			var result = space_state.intersect_ray(query)
			
			var target_point = to
			if result:
				target_point = result.position
			
			if spawn_transform.origin.distance_squared_to(target_point) > 0.2:
				var up_dir = Vector3.UP
				if abs(spawn_transform.origin.direction_to(target_point).y) > 0.99:
					up_dir = Vector3.RIGHT
				spawn_transform = spawn_transform.looking_at(target_point, up_dir)
		if spread_angle > 0.0:
			var spread_x = randf_range(-spread_angle, spread_angle)
			var spread_y = randf_range(-spread_angle, spread_angle)
			spawn_transform.basis = spawn_transform.basis.rotated(spawn_transform.basis.x, deg_to_rad(spread_x))
			spawn_transform.basis = spawn_transform.basis.rotated(spawn_transform.basis.y, deg_to_rad(spread_y))
			
		if bullet.has_method("fire"):
			bullet.fire(spawn_transform);
		
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
