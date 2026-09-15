extends Node3D

@export var spawn_interval: float = 1.5
@export var max_active_targets: int = 6

var weak_scene = preload("res://scenes/alvo_fraco.tscn")
var strong_scene = preload("res://scenes/alvo_forte.tscn")

var timer: Timer
var spots = []
var active_spots = {}
var time_elapsed: float = 0.0

func get_current_diff_mult() -> float:
	var diff_mult = 1.0
	if Global.current_difficulty == Global.Difficulty.FACIL:
		diff_mult = 1.5
	elif Global.current_difficulty == Global.Difficulty.DIFICIL:
		diff_mult = 0.6
		
	# Dificuldade progressiva: a cada 10 segundos o tempo cai em 5%, limite de metade do tempo original
	var progress = time_elapsed / 10.0
	var scale_factor = max(0.5, 1.0 - (progress * 0.05))
	
	return diff_mult * scale_factor

func _process(delta: float) -> void:
	time_elapsed += delta
	if is_instance_valid(timer):
		timer.wait_time = spawn_interval * get_current_diff_mult()

func _ready():
	randomize()
	for child in get_children():
		if child is Marker3D:
			spots.append(child)
			
	timer = Timer.new()
	timer.wait_time = spawn_interval * get_current_diff_mult()
	timer.autostart = true
	timer.timeout.connect(_on_spawn_timer)
	add_child(timer)

func _on_spawn_timer():
	var to_erase = []
	for spot in active_spots:
		if not is_instance_valid(active_spots[spot]):
			to_erase.append(spot)
	for spot in to_erase:
		active_spots.erase(spot)
		
	if active_spots.size() >= max_active_targets or spots.is_empty():
		return
		
	var available_spots = []
	for spot in spots:
		if not active_spots.has(spot):
			available_spots.append(spot)
			
	if available_spots.is_empty():
		return
		
	var chosen_spot = available_spots.pick_random()
	spawn_target_at(chosen_spot)

func spawn_target_at(spot: Marker3D):
	var is_far = spot.global_position.z < -40.0
	var is_close = spot.global_position.z > -15.0
	
	var is_strong = randf() < 0.3 # 30% de chance normal
	
	if is_close:
		is_strong = randf() < 0.9 # 90% de chance de ser forte nas muretas CQB
	
	var target_scene = strong_scene if is_strong else weak_scene
	var target = target_scene.instantiate()
	
	get_parent().add_child(target)
	
	var final_y = spot.global_position.y
	target.global_position = spot.global_position
	# Começa escondido embaixo do chão ou mureta
	target.global_position.y = final_y - 2.5
	active_spots[spot] = target
	
	var wait_time = 0.0
	if is_strong:
		wait_time = randf_range(8.0, 10.0) if is_far else randf_range(6.0, 8.0)
	else:
		wait_time = randf_range(6.0, 8.0) if is_far else randf_range(3.0, 5.0)
		
	wait_time *= get_current_diff_mult()
		
	var tween = target.create_tween()
	# Sobe lentamente
	tween.tween_property(target, "global_position:y", final_y, 0.8).set_trans(Tween.TRANS_SINE)
	# Espera
	tween.tween_interval(wait_time)
	# Desce lentamente
	tween.tween_property(target, "global_position:y", final_y - 2.5, 0.8).set_trans(Tween.TRANS_SINE)
	# Deleta
	tween.tween_callback(target.queue_free)
