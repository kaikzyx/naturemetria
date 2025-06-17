extends CanvasLayer

const _INTERVAL_TIME := 7.5

func _ready() -> void:
	await get_tree().create_timer(_INTERVAL_TIME).timeout
	Global.main.change_scene(&"interface/credits_ui", Main.Transition.FADE, 1.5)
