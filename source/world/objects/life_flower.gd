extends Area2D

@onready var _pivot: Vector2 = global_position

func _physics_process(delta: float) -> void:
	global_position.y = _pivot.y + sin(Time.get_ticks_msec() * 0.1 * delta) * 8

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		get_tree().paused = true

		var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_interval(1)
		tween.tween_callback(Global.main.change_scene.bind(&"interface/end_ui", Main.Transition.FADE, 1.5))
