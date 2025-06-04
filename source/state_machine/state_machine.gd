class_name StateMachine extends Node

signal state_changed(from: State, to: State)

@export var initial_state: State
var current_state: State

func start() -> void:
	assert(is_instance_valid(initial_state), "The state machine needs an initial state.")

	# Initialize.
	current_state = initial_state
	current_state.entered.emit()
	state_changed.emit(null, current_state)

func _process(delta: float) -> void:
	if is_instance_valid(current_state):
		current_state.updated.emit(delta)

func _physics_process(delta: float) -> void:
	if is_instance_valid(current_state):
		current_state.physics_updated.emit(delta)

func request_state(state: StringName) -> void:
	var pascal := state.to_pascal_case() as StringName
	var new_state := get_node_or_null(pascal + &"State") as State
	var transition := current_state.get_node_or_null(&"On" + pascal) as StateTransition

	if is_instance_valid(transition) and is_instance_valid(new_state) and new_state != current_state:
		var previous := current_state
		previous.exited.emit()
		current_state = new_state
		current_state.entered.emit()
		state_changed.emit(previous, current_state)
