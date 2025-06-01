class_name Camera extends Camera2D

@export var target: Node2D

func _ready() -> void:
	global_position = target.global_position

func _process(delta: float) -> void:
	global_position = global_position.lerp(target.global_position, 5 * delta)
