class_name Effect extends AnimatedSprite2D

func _ready() -> void:
	z_index = RenderingServer.CANVAS_ITEM_Z_MAX

	await animation_finished
	queue_free()
