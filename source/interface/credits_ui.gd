extends CanvasLayer

@onready var _credits_label: Control = $Background/CreditsLabel

const _CREDITS_TIME := 20.0

func _ready() -> void:
	_credits_label.position.y = get_viewport().size.y

	var tween := create_tween()
	tween.tween_interval(1)
	tween.tween_property(_credits_label, ^"position:y", -_credits_label.size.y, _CREDITS_TIME)
	tween.tween_interval(0.5)
	tween.tween_callback(Global.main.change_scene.bind(&"interface/thanks_ui", Main.Transition.FADE,  1.5))
