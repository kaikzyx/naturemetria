extends Node2D

func _on_player_died() -> void:
	Global.main.change_scene(preload("res://source/world/world.tscn"))
