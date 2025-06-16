extends Node2D

@onready var _word_ui: WordUI = $WordUI

const _KILLED_SCORE_LABEL_OFFSET := Vector2(0, -16.0)
const _CONSUMED_SCORE_LABEL_OFFSET := Vector2(0, -32.0)

func _on_main_ready(main: Main) -> void:
	main.interface.add_child(_word_ui)

func _on_player_died() -> void:
	Global.main.change_scene(preload("res://source/world/world.tscn"))

func _on_player_transformed(status: bool) -> void:
	if is_instance_valid(_word_ui):
		_word_ui.refresh_power_up_panel(status)

func _on_player_killed() -> void:
	if is_instance_valid(_word_ui):
		_word_ui.add_score(100, Global.player.global_position + _KILLED_SCORE_LABEL_OFFSET)

func _on_player_consumed() -> void:
	if is_instance_valid(_word_ui):
		_word_ui.add_score(250, Global.player.global_position + _CONSUMED_SCORE_LABEL_OFFSET)
