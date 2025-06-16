extends Node

signal main_ready(main: Main)

var main: Main:
	set(value):
		if is_instance_valid(value):
			main_ready.emit(value)
			main = value

var player: Player
