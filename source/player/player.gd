class_name Player extends CharacterBody2D

@onready var _sprite: Sprite2D = $Sprite
@onready var _state_machine: StateMachine = $StateMachine

var speed := 100.0
var damping := 10.0
var direction := 1
var jump_force := 250.0
var knockback := 250.0

func _physics_process(_delta: float) -> void:
	# Change the sprite direction.
	_sprite.flip_h = direction == -1

	move_and_slide()

func _get_movement_direction() -> int:
	return Input.get_axis(&"move_left", &"move_right") as int

func _system_movement(delta: float) -> void:
	var movement := _get_movement_direction()
	velocity.x = lerp(velocity.x, movement * speed, damping * delta)
	if movement != 0: direction = movement

func  _system_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting(&"physics/2d/default_gravity") * delta

func _on_hitbox_area_entered(area: Area2D) -> void:
	velocity.y = -knockback
	area.owner.queue_free()

func _on_hurtbox_body_entered(_body: Node2D) -> void:
	queue_free()

#region State machine callbacks.

func _on_state_machine_state_changed(from: State, to: State) -> void:
	var message := &"Player state changed from: {0}, to: {1}."
	print(message.format([from.get_state_name() if from else &"null", to.get_state_name()]))

func _on_idle_physics_updated(delta: float) -> void:
	_system_movement(delta)
	_system_gravity(delta)

	if _get_movement_direction() != 0: _state_machine.request_state(&"run")
	if Input.is_action_just_pressed(&"jump"): _state_machine.request_state(&"jump")

func _on_run_physics_updated(delta: float) -> void:
	_system_movement(delta)
	_system_gravity(delta)

	if _get_movement_direction() == 0: _state_machine.request_state(&"idle")
	if Input.is_action_just_pressed(&"jump"): _state_machine.request_state(&"jump")

func _on_jump_state_entered() -> void:
	velocity.y = -jump_force

func _on_jump_state_physics_updated(delta: float) -> void:
	_system_movement(delta)
	_system_gravity(delta)

	if velocity.y > 0: _state_machine.request_state(&"fall")

func _on_fall_state_physics_updated(delta: float) -> void:
	_system_movement(delta)
	_system_gravity(delta)

	if is_on_floor(): _state_machine.request_state(&"idle" if _get_movement_direction() == 0 else &"run")

#endregion
