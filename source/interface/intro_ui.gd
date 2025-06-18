extends CanvasLayer

func _ready() -> void:
	Global.main.music(preload("res://assets/sounds/main_theme.wav"))

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"resume") and not Global.main.in_transition:
		Global.main.change_scene(&"world/world", Main.Transition.DIAMOND, 1.5)
