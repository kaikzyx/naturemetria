extends Label

const _CLIMB_SPEED := 10.0

func _ready() -> void:
	position -= size / 2
	pivot_offset = size / 2
	scale = Vector2.ZERO
	z_index = RenderingServer.CANVAS_ITEM_Z_MAX

	var tween := get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, ^"scale", Vector2.ONE, 0.25)
	tween.tween_interval(0.5)
	tween.tween_property(self, ^"modulate:a", 0.0, 0.25)
	tween.tween_callback(queue_free)

func _physics_process(delta: float) -> void:
	position.y -= _CLIMB_SPEED * delta
