extends Node3D

@onready var player = $Player

var time_left: float = 0.0
var game_active: bool = true

func _ready() -> void:
	# Add some magazines to the world for the player to collect
	# Timer para spawnar carregadores continuamente
	var mag_timer = Timer.new()
	mag_timer.name = "MagTimer"
	mag_timer.wait_time = randf_range(3.0, 6.0)
	mag_timer.autostart = true
	mag_timer.timeout.connect(_spawn_random_magazine)
	add_child(mag_timer)
	
	# Spawna 3 iniciais
	for i in range(3):
		_spawn_random_magazine()
		
	if Global.current_game_mode == Global.GameMode.QUICK:
		time_left = 60.0
	elif Global.current_game_mode == Global.GameMode.CUSTOM:
		time_left = float(Global.custom_time_limit)
	else:
		game_active = false # Treino

func _process(delta: float) -> void:
	if game_active and time_left > 0:
		time_left -= delta
		if time_left <= 0:
			time_left = 0
			end_game()
		
		# We can send an event to HUD here or let HUD poll
		Global.time_changed.emit(int(time_left))

func _input(event: InputEvent) -> void:
	if Global.current_game_mode == Global.GameMode.TREINO:
		if event is InputEventKey and event.keycode == KEY_BACKSPACE and event.pressed:
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func end_game() -> void:
	game_active = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Pause targets or just disable player
	player.set_physics_process(false)
	player.set_process_input(false)
	if player.has_node("WeaponManager"):
		player.get_node("WeaponManager").set_process_input(false)
	
	var is_record = false
	if Global.current_game_mode == Global.GameMode.QUICK and Global.score > Global.quick_record:
		Global.save_record(Global.score)
		is_record = true
		
	# Show End Screen overlay
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	add_child(canvas)
	
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.8)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(overlay)
	
	var center_container = CenterContainer.new()
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center_container)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	center_container.add_child(vbox)
	
	var title = Label.new()
	title.text = "FIM DE JOGO"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	vbox.add_child(title)
	
	var score_lbl = Label.new()
	score_lbl.text = "Pontuação: " + str(Global.score)
	score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_lbl.add_theme_font_size_override("font_size", 32)
	vbox.add_child(score_lbl)
	
	if is_record:
		var rec_lbl = Label.new()
		rec_lbl.text = "NOVO RECORDE!"
		rec_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rec_lbl.add_theme_color_override("font_color", Color(1, 0.84, 0))
		rec_lbl.add_theme_font_size_override("font_size", 32)
		vbox.add_child(rec_lbl)
		
	var btn = Button.new()
	btn.text = "Voltar ao Menu"
	btn.custom_minimum_size = Vector2(200, 60)
	btn.add_theme_font_size_override("font_size", 24)
	btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
	vbox.add_child(btn)

func _spawn_random_magazine() -> void:
	if has_node("MagTimer"):
		get_node("MagTimer").wait_time = randf_range(3.0, 6.0)

	var area = MagazinePickup.new()
	var col = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(1, 1, 1)
	col.shape = shape
	area.add_child(col)
	
	var type = randi() % 4 as Enums.WeaponType
	var type_name = ""
	var color = Color(1, 1, 1)
	var icon_path = ""
	
	if type == Enums.WeaponType.SHOTGUN:
		type_name = "Shotgun"
		color = Color(0.8, 0.2, 0.2) # Vermelho
		icon_path = "res://resources/icons/shotgun.svg"
	elif type == Enums.WeaponType.RIFLE:
		type_name = "Rifle"
		color = Color(0.2, 0.4, 0.8) # Azul
		icon_path = "res://resources/icons/rifle.svg"
	elif type == Enums.WeaponType.SNIPER:
		type_name = "Sniper"
		color = Color(0.2, 0.8, 0.2) # Verde
		icon_path = "res://resources/icons/sniper.svg"
	elif type == Enums.WeaponType.PISTOLGLOCK:
		type_name = "Glock"
		color = Color(0.8, 0.4, 0.8) # Roxo
		icon_path = "res://resources/icons/glock.svg"

		
	# Visual cube
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.3, 0.3, 0.3)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	box.material = mat
	mesh.mesh = box
	area.add_child(mesh)
	
	# Floating Icon
	var sprite = Sprite3D.new()
	var texture = load(icon_path)
	if texture:
		sprite.texture = texture
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.pixel_size = 0.005
	sprite.position = Vector3(0, 0.6, 0)
	sprite.modulate = color
	area.add_child(sprite)

	# Floating text
	var label = Label3D.new()
	label.text = type_name
	label.pixel_size = 0.005
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, 0.35, 0)
	label.modulate = color
	label.outline_modulate = Color(0, 0, 0)
	label.outline_size = 4
	area.add_child(label)
	
	var res = MagazineResource.new()
	res.type = type
	res.capacity = 30 if type == Enums.WeaponType.RIFLE else 15
	res.current_ammo = res.capacity
	var possible_masses = [0.00020, 0.00025, 0.00032]
	res.mass_kg = possible_masses[randi() % possible_masses.size()]
	area.magazine_data = res
	
	add_child(area)
	# Spawna aleatoriamente ao redor do centro da base
		# Spawna ao redor do player, mas em uma posição segura
	var player_pos = Vector3.ZERO
	if has_node("Player"):
		player_pos = get_node("Player").global_position
	
	var spawn_x = player_pos.x + randf_range(-4, 4)
	var spawn_z = player_pos.z + randf_range(-4, 4)
	var spawn_y = player_pos.y + 2.0 # Start a bit above the player
	
	# Raycast down to find the floor
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(Vector3(spawn_x, spawn_y, spawn_z), Vector3(spawn_x, -100.0, spawn_z))
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)
	
	if result:
		spawn_y = result.position.y + 0.15 # 0.15 is half the box height (0.3)
	else:
		spawn_y = 0.15 # Fallback if raycast fails
		
	area.global_position = Vector3(spawn_x, spawn_y, spawn_z)
