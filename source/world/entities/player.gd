class_name Player extends CharacterBody2D

signal died()

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var _state_machine: StateMachine = $StateMachine

const _SPEED := 100.0
const _SPEED_DAMPING := 10.0
const _JUMP_FORCE := 250.0
const _KNOCKBACK_FORCE := 250.0
const _DEAD_FREEZE_TIME := 0.5
const _DEAD_INTERVAL_TIME := 0.25
const _DEAD_KNOCKBACK := 250.0
const _DEAD_GRAVITY_FORCE := 500.0
var direction := 1
var is_super := false

func _ready() -> void:
	Global.player = self
	_state_machine.start()

func _physics_process(_delta: float) -> void:
	# Change the sprite direction.
	_animated_sprite.flip_h = direction == -1

	move_and_slide()

func damage() -> void:
	if is_super:
		_state_machine.request_state(&"transform")
	else:
		_state_machine.request_state(&"dead_freeze")

func _get_horizontal_direction() -> int:
	return Input.get_axis(&"move_left", &"move_right") as int

func _get_vertical_direction() -> int:
	return Input.get_axis(&"move_up", &"move_down") as int

func _platform_movement(delta: float) -> void:
	var movement := _get_horizontal_direction()
	velocity.x = lerp(velocity.x, movement * _SPEED, _SPEED_DAMPING * delta)
	if movement != 0: direction = movement

	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting(&"physics/2d/default_gravity") * delta

func _top_down_movement(delta: float) -> void:
	var movement := Vector2(_get_horizontal_direction(), _get_vertical_direction()).normalized()
	velocity = velocity.lerp(movement * _SPEED, _SPEED_DAMPING * delta)
	if movement.x != 0: direction = sign(movement.x)

func _on_hitbox_area_entered(area: Area2D) -> void:
	var area_owner := area.owner

	if area_owner is Cloud:
		if _state_machine.get_current_state() == &"jump":
			area_owner.hit()
		return

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Star:
		_state_machine.request_state(&"transform")
		body.queue_free()

	if body is Enemy:
		if _state_machine.get_current_state() == &"fall":
			velocity.y = -_KNOCKBACK_FORCE
			body.kill()
		else:
			damage()

func _on_water_detector_body_entered(_body: Node2D) -> void:
	_state_machine.request_state(&"swin_idle")

func _on_water_detector_body_exited(_body: Node2D) -> void:
	_state_machine.request_state(&"jump")

#region State machine callbacks.

func _on_state_machine_state_changed(_from: State, to: State) -> void:
	print(&"Player state changed to: " + to.get_state_name())

func _on_idle_state_entered() -> void:
	_animated_sprite.play(&"super_idle" if is_super else &"small_idle")

func _on_idle_physics_updated(delta: float) -> void:
	_platform_movement(delta)

	if _get_horizontal_direction() != 0: _state_machine.request_state(&"run")
	if is_on_floor() and Input.is_action_just_pressed(&"jump"): _state_machine.request_state(&"jump")
	if velocity.y > 0: _state_machine.request_state(&"fall")

func _on_run_state_entered() -> void:
	_animated_sprite.play(&"super_run" if is_super else &"small_run")

func _on_run_physics_updated(delta: float) -> void:
	_platform_movement(delta)

	if _get_horizontal_direction() == 0: _state_machine.request_state(&"idle")
	if is_on_floor() and Input.is_action_just_pressed(&"jump"): _state_machine.request_state(&"jump")
	if velocity.y > 0: _state_machine.request_state(&"fall")

func _on_jump_state_entered() -> void:
	_animated_sprite.play(&"super_jump" if is_super else &"small_jump")
	velocity.y = -_JUMP_FORCE

func _on_jump_state_physics_updated(delta: float) -> void:
	_platform_movement(delta)

	if velocity.y > 0: _state_machine.request_state(&"fall")

func _on_fall_state_entered() -> void:
	_animated_sprite.play(&"super_fall" if is_super else &"small_fall")

func _on_fall_state_physics_updated(delta: float) -> void:
	_platform_movement(delta)

	if is_on_floor(): _state_machine.request_state(&"idle" if _get_horizontal_direction() == 0 else &"run")

func _on_swin_idle_state_entered() -> void:
	_animated_sprite.play(&"super_swin_idle" if is_super else &"small_swin_idle")

func _on_swin_idle_state_physics_updated(delta: float) -> void:
	velocity = velocity.lerp(Vector2.ZERO, _SPEED_DAMPING * delta)

	if _get_horizontal_direction() != 0 or _get_vertical_direction() != 0:
		_state_machine.request_state(&"swin_move")

func _on_swin_move_state_entered() -> void:
	_animated_sprite.play(&"super_swin_move" if is_super else &"small_swin_move")

func _on_swin_move_state_physics_updated(delta: float) -> void:
	_top_down_movement(delta)

	if _get_horizontal_direction() == 0 and _get_vertical_direction() == 0:
		_state_machine.request_state(&"swin_idle")

func _on_transform_state_entered() -> void:
	get_tree().paused = true
	velocity = Vector2.ZERO
	is_super = not is_super

	if is_super:
		_animated_sprite.play_backwards(&"transform")
	else:
		_animated_sprite.play(&"transform")

	await _animated_sprite.animation_finished
	get_tree().paused = false
	_state_machine.request_state(&"idle")

func _on_dead_freeze_state_entered() -> void:
	get_tree().paused = true

	# Configure player death.
	collision_layer = 0
	collision_mask = 0
	velocity = Vector2.ZERO
	z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	_animated_sprite.play(&"dead")
	_animated_sprite.pause()

	# Wait for the timer and the real state of death begins.
	await get_tree().create_timer(_DEAD_FREEZE_TIME).timeout
	_state_machine.request_state(&"dead")

func _on_dead_state_entered() -> void:
	_animated_sprite.play(&"dead")
	velocity.y = -_DEAD_KNOCKBACK

func _on_dead_state_physics_updated(delta: float) -> void:
	velocity.y += _DEAD_GRAVITY_FORCE * delta

	# Emit died signal when the player disappears from the screen.
	if global_position.y > get_viewport_rect().size.y:
		await get_tree().create_timer(_DEAD_INTERVAL_TIME).timeout

		died.emit()
		queue_free()

#endregion
