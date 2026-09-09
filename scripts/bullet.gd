class_name Bullet
extends Area3D

signal bonk_something;

@export_category("Physics Settings")
@export var joules: float = 1.49;
@export_range(0.0, 1000.0, 0.00001) var mass_kg: float = 0.0002;	
@export_range(0.0, 10.0, 0.001) var drag_coefficient: float = 0.47;
@export_range(0.0, 10.0, 0.001) var bb_radius: float = 0.003;
var cross_section_area: float = PI * pow(bb_radius, 2);
var air_density: float = 1.225
var air_dynamic_viscosity: float = 0.0000181

@export var backspin_rpm: float = 6000;
var spin_vector: Vector3 = Vector3.ZERO

var velocity: Vector3 = Vector3.ZERO;
var gravity_vector_setting: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector", Vector3.DOWN);
var gravity_value_setting: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8);
var gravity_vector: Vector3 = gravity_vector_setting * gravity_value_setting;

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is Mira:
		hit()

func fire(start_transform: Transform3D) -> void:
	global_transform = start_transform;
	scale = Vector3.ONE;
	var speed = sqrt((2.0 * joules) / mass_kg);
	velocity = -global_transform.basis.z.normalized() * speed;
	var rad_per_sec = backspin_rpm * (PI / 30.0)
	spin_vector = global_basis.x.normalized() * rad_per_sec

func _physics_process(delta: float) -> void:
	velocity += gravity_vector * delta;
	
	var current_speed_sq = velocity.length_squared();
	if current_speed_sq > 0.0001:
		var current_speed = sqrt(current_speed_sq);
		var drag_force = 0.5 * air_density * current_speed_sq * drag_coefficient * cross_section_area;
		var drag_acceleration = drag_force / mass_kg;
		var move_direction = velocity / current_speed;
		velocity -= move_direction * drag_acceleration * delta;
		
		var spin_speed = spin_vector.length();
		if spin_speed > 0.1:
			var cross_prod = spin_vector.cross(velocity);
			if cross_prod.length_squared() > 0.0001:
				var magnus_direction = spin_vector.cross(velocity).normalized()
				var magnus_force = 0.5 * air_density * cross_section_area * bb_radius * spin_speed * current_speed;
				var magnus_accel = magnus_force / mass_kg;
				
				velocity += magnus_direction * magnus_accel * delta;
				
				var momento_inercia = 0.4 * mass_kg * pow(bb_radius, 2)
				var torque_atrito = -8.0 * PI * air_dynamic_viscosity * pow(bb_radius, 3) * spin_vector
				var aceleracao_angular = torque_atrito / momento_inercia
				spin_vector += aceleracao_angular * delta
	
	var next_position = global_position + velocity * delta
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, next_position)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)
	
	if result:
		global_position = result.position
		if result.collider is Mira:
			hit()
		else:
			queue_free()
	else:
		global_position = next_position

func hit():
	queue_free();
	bonk_something.emit();

func _on_life_time_timeout() -> void:
	queue_free();
