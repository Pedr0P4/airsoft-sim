extends Node3D

@onready var player = $Player

var time_left: float = 0.0
var game_active: bool = true

func _ready() -> void:
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
