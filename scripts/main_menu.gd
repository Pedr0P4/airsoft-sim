extends Control

@onready var difficulty_btn: OptionButton = $VBoxContainer/DifficultyContainer/DifficultyOption
@onready var mode_btn: OptionButton = $VBoxContainer/ModeContainer/ModeOption
@onready var custom_time_container: HBoxContainer = $VBoxContainer/CustomTimeContainer
@onready var custom_time_edit: LineEdit = $VBoxContainer/CustomTimeContainer/TimeEdit
@onready var record_label: Label = $VBoxContainer/RecordLabel

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	difficulty_btn.add_item("Fácil")
	difficulty_btn.add_item("Médio")
	difficulty_btn.add_item("Difícil")
	difficulty_btn.select(Global.current_difficulty)
	
	mode_btn.add_item("Treino")
	mode_btn.add_item("Quick (60s)")
	mode_btn.add_item("Tempo Custom")
	mode_btn.select(Global.current_game_mode)
	
	custom_time_edit.text = str(Global.custom_time_limit)
	_on_mode_option_item_selected(Global.current_game_mode)
	
	record_label.text = "Recorde Quick: " + str(Global.quick_record)

func _on_play_button_pressed() -> void:
	Global.current_difficulty = difficulty_btn.selected as Global.Difficulty
	Global.current_game_mode = mode_btn.selected as Global.GameMode
	
	if Global.current_game_mode == Global.GameMode.CUSTOM:
		var parsed_time = custom_time_edit.text.to_int()
		if parsed_time > 0:
			Global.custom_time_limit = parsed_time
		else:
			Global.custom_time_limit = 60 # fallback
	
	Global.score = 0
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_mode_option_item_selected(index: int) -> void:
	if index == Global.GameMode.CUSTOM:
		custom_time_container.show()
	else:
		custom_time_container.hide()
