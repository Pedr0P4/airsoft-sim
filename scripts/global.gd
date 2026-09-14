extends Node

signal score_changed(new_score: int)
signal points_received(points: int)

var score: int = 0

func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)
	points_received.emit(points)

func remove_score(points: int) -> void:
	score -= points
	if score < 0:
		score = 0
	score_changed.emit(score)
	points_received.emit(-points)
