extends CanvasLayer

func _ready() -> void:
	Global.main.music(preload("res://assets/sounds/credits_theme.wav"))

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"resume") and not Global.main.in_transition:
		Global.main.change_scene(&"interface/credits_ui", Main.Transition.FADE, 1.5)
