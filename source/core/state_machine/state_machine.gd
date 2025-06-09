class_name StateMachine extends Node

signal state_changed(from: State, to: State)

@export var initial_state: State
var _current_state: State

func start() -> void:
	assert(is_instance_valid(initial_state), "The state machine needs an initial state.")

	# Initialize.
	_current_state = initial_state
	_current_state.entered.emit()
	state_changed.emit(null, _current_state)

func _process(delta: float) -> void:
	if is_instance_valid(_current_state):
		_current_state.updated.emit(delta)

func _physics_process(delta: float) -> void:
	if is_instance_valid(_current_state):
		_current_state.physics_updated.emit(delta)

func get_current_state() -> StringName:
	if not is_instance_valid(_current_state): return &"";
	return _current_state.get_state_name()

func request_state(state: StringName) -> void:
	var new_state := get_node_or_null(state.to_pascal_case() + &"State") as State

	if is_instance_valid(new_state) and new_state != _current_state:
		var previous := _current_state
		previous.exited.emit()
		_current_state = new_state
		_current_state.entered.emit()
		state_changed.emit(previous, _current_state)
