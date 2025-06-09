class_name Main extends Node

@export var current: Node

@onready var _transition_animation: AnimationPlayer = $Transition/Animation
const _INTERVAL_TRANSITION_TIME := 0.5

func _ready() -> void:
	Global.main = self

func change_scene(scene: PackedScene) -> void:
	if not is_instance_valid(current): return

	get_tree().paused = true
	_transition_animation.play(&"fade_out")
	await _transition_animation.animation_finished

	var instance := scene.instantiate()
	current.get_parent().add_child(instance)
	current.queue_free()
	current = instance

	await get_tree().create_timer(_INTERVAL_TRANSITION_TIME).timeout

	get_tree().paused = false
	_transition_animation.play(&"fade_in")
