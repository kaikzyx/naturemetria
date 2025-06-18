class_name Main extends Node

enum Transition {
	FADE,
	CIRCLE,
	DIAMOND,
}

@export var _initial_scene: PackedScene
@onready var _base_node: Node = $SubViewportContainer/SubViewport
@onready var _transition_animation: AnimationPlayer = $Transition/Animation
@onready var _interface: Control = $Interface
@onready var _audio_stream: AudioStreamPlayer = $AudioStream

const _AUDIO_FADE_TIME := 0.75
const _AUDIO_MIN_DB := -80.0
const _AUDIO_MAX_DB := -30.0
const _INTERVAL_TRANSITION_TIME := 0.5
var current: Node

func _ready() -> void:
	Global.main = self

	assert(_initial_scene, "Put the initial scene.")
	current = _initial_scene.instantiate()
	_base_node.add_child(current)

func change_scene(path: StringName, transition: Transition, interval: float = _INTERVAL_TRANSITION_TIME) -> void:
	if not is_instance_valid(current): return

	var transition_name: String

	match transition:
		Transition.FADE:
			transition_name = &"fade"
		Transition.CIRCLE:
			transition_name = &"circle"
		Transition.DIAMOND:
			transition_name = &"diamond"

	get_tree().paused = true
	_transition_animation.play(transition_name + &"_out")
	await _transition_animation.animation_finished

	var instance: Node = load("res://source/" + path + ".tscn").instantiate()
	current.queue_free()
	current = instance
	
	if instance.is_in_group(&"interface"):
		_interface.add_child(instance)
	else:
		_base_node.add_child(instance)

	await get_tree().create_timer(interval).timeout

	get_tree().paused = false
	_transition_animation.play(transition_name + &"_in")

func music(audio: AudioStream) -> void:
	var tween := create_tween()
	tween.tween_property(_audio_stream, ^"volume_db", _AUDIO_MIN_DB, _AUDIO_FADE_TIME)
	tween.tween_callback(func() -> void:
		if audio:
			_audio_stream.stream = audio
			_audio_stream.play()
			create_tween().tween_property(_audio_stream, ^"volume_db", _AUDIO_MAX_DB, _AUDIO_FADE_TIME))
