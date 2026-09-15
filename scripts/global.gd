extends Node

signal score_changed(new_score: int)
signal points_received(points: int)
signal time_changed(time_left: int)
signal feedback_received(message: String)

var score: int = 0

# Configurações do Jogo
enum Difficulty { FACIL, MEDIO, DIFICIL }
enum GameMode { TREINO, QUICK, CUSTOM }

var current_difficulty: Difficulty = Difficulty.MEDIO
var current_game_mode: GameMode = GameMode.QUICK
var custom_time_limit: int = 60

var quick_record: int = 0
const SAVE_PATH = "user://save_data.cfg"

func _ready() -> void:
	load_record()

func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)
	points_received.emit(points)

func emit_feedback(message: String) -> void:
	feedback_received.emit(message)

func remove_score(points: int) -> void:
	score -= points
	if score < 0:
		score = 0
	score_changed.emit(score)
	points_received.emit(-points)

func save_record(new_record: int) -> void:
	quick_record = new_record
	var config = ConfigFile.new()
	config.set_value("Stats", "quick_record", quick_record)
	config.save(SAVE_PATH)

func load_record() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		quick_record = config.get_value("Stats", "quick_record", 0)
	else:
		quick_record = 0
