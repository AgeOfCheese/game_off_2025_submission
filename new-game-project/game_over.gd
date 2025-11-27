extends Control

func show_game_over():
	visible = true
	get_tree().paused = true

func _on_RestartButton_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
