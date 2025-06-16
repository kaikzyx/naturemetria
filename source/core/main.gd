class_name Main extends Node

@export var _initial_scene: PackedScene
@onready var _base_node: Node = $SubViewportContainer/SubViewport
@onready var _transition_animation: AnimationPlayer = $Transition/Animation

const _INTERVAL_TRANSITION_TIME := 0.5
var current: Node

func _ready() -> void:
	Global.main = self

	assert(_initial_scene, "Put the initial scene.")
	current = _initial_scene.instantiate()
	_base_node.add_child(current)

func change_scene(scene: PackedScene, interval: float = _INTERVAL_TRANSITION_TIME) -> void:
	if not is_instance_valid(current): return

	get_tree().paused = true
	_transition_animation.play(&"fade_out")
	await _transition_animation.animation_finished

	var instance := scene.instantiate()
	_base_node.add_child(instance)
	current.queue_free()
	current = instance

	await get_tree().create_timer(interval).timeout

	get_tree().paused = false
	_transition_animation.play(&"fade_in")
