extends CanvasLayer

const _INTERVAL_TIME := 10.0

func _ready() -> void:
	await get_tree().create_timer(_INTERVAL_TIME).timeout
	Global.main.change_scene(&"world/world", Main.Transition.DIAMOND, 1.5)
