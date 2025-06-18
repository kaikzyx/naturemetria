class_name Player extends CharacterBody2D

signal died()
signal transformed(status: bool)
signal killed()
signal consumed()

@onready var state_machine: StateMachine = $StateMachine
@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var _animation: AnimationPlayer = $Animation
@onready var _ground_detector: Area2D = $GroundDetector
@onready var _audio_stream: AudioStreamPlayer = $AudioStream

const _SPEED := 100.0
const _SPEED_DAMPING := 10.0
const _JUMP_FORCE := 300.0
const _JUMP_BRAKE_FACTOR := 0.5
const _JUMP_HANG_THRESHOLD := 32.0
const _JUMP_HANG_GRAVITY_FACTOR := 0.5
const _KNOCKBACK_FORCE := 250.0
const _DEAD_FREEZE_TIME := 0.5
const _DEAD_KNOCKBACK := 250.0
const _DEAD_GRAVITY_FORCE := 500.0
const _COYOTE_TIME := 0.25
const _JUMP_BUFFER_TIME := 0.1
var _coyote_clock := 0.0
var _jump_buffer_clock := 0.0
var direction := 1
var is_super := false
var is_dead

func _ready() -> void:
	Global.player = self
	state_machine.start()

func _process(delta: float) -> void:
	_coyote_clock -= delta
	_jump_buffer_clock -= delta

func _physics_process(_delta: float) -> void:
	# Change the sprite direction.
	_animated_sprite.flip_h = direction == -1

	move_and_slide()

func damage() -> void:
	if is_super:
		state_machine.request_state(&"transform")
	else:
		state_machine.request_state(&"dead_freeze")

func consume() -> void:
	if not is_super:
		_sound_effect(preload("res://assets/sounds/player_power_up_sound_effect.wav"))
		state_machine.request_state(&"transform")
	consumed.emit()

func _sound_effect(audio: AudioStream) -> void:
	_audio_stream.stream = audio
	_audio_stream.play()
	await _audio_stream.finished
	_audio_stream.stream = null

func _smoke_effect() -> void:
	var effect := preload("res://source/world/effects/smoke_effect.tscn").instantiate()
	effect.global_position = global_position
	Global.main.current.add_child(effect)

func _splash_effect() -> void:
	var effect := preload("res://source/world/effects/splash_effect.tscn").instantiate()
	effect.global_position = global_position - Vector2(0, 8)
	Global.main.current.add_child(effect)

func _kick_effect() -> void:
	_sound_effect(preload("res://assets/sounds/player_kick_sound_effect.wav"))
	var effect := preload("res://source/world/effects/kick_effect.tscn").instantiate()
	effect.global_position = global_position
	Global.main.current.add_child(effect)

func _get_horizontal_direction() -> int:
	return Input.get_axis(&"move_left", &"move_right") as int

func _get_vertical_direction() -> int:
	return Input.get_axis(&"move_up", &"move_down") as int

func _platform_movement(delta: float) -> void:
	var movement := _get_horizontal_direction()
	velocity.x = lerp(velocity.x, movement * _SPEED, _SPEED_DAMPING * delta)
	if movement != 0: direction = movement

	if Input.is_action_just_pressed(&"jump"):
		_jump_buffer_clock = _JUMP_BUFFER_TIME

	if is_on_floor():
		_coyote_clock = _COYOTE_TIME
	else:
		var gravity := ProjectSettings.get_setting(&"physics/2d/default_gravity") as float
		if abs(velocity.y) <= _JUMP_HANG_THRESHOLD: gravity *= _JUMP_HANG_GRAVITY_FACTOR
		velocity.y += gravity * delta

func _can_jump() -> bool:
	return _coyote_clock > 0 and _jump_buffer_clock > 0

func _top_down_movement(delta: float) -> void:
	var movement := Vector2(_get_horizontal_direction(), _get_vertical_direction()).normalized()
	velocity = velocity.lerp(movement * _SPEED, _SPEED_DAMPING * delta)
	if movement.x != 0: direction = sign(movement.x)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Enemy:
		if state_machine.get_current_state() == &"fall":
			velocity.y = -_KNOCKBACK_FORCE
			body.kill()
			killed.emit()
			_kick_effect()
		else:
			damage()

func _on_ground_detector_body_entered(_body: Node2D) -> void:
	if _ground_detector.get_overlapping_bodies().size() == 1:
		_animation.play(&"squash")
		_smoke_effect()

func _on_water_detector_body_entered(_body: Node2D) -> void:
	state_machine.request_state(&"swin_idle")
	_splash_effect()

func _on_water_detector_body_exited(_body: Node2D) -> void:
	state_machine.request_state(&"jump")
	_splash_effect()

#region State machine callbacks.

func _on_idle_state_entered() -> void:
	_animated_sprite.play(&"super_idle" if is_super else &"small_idle")

func _on_idle_physics_updated(delta: float) -> void:
	_platform_movement(delta)

	if _get_horizontal_direction() != 0: state_machine.request_state(&"run")
	if _can_jump(): state_machine.request_state(&"jump")
	if velocity.y > 0: state_machine.request_state(&"fall")

func _on_run_state_entered() -> void:
	_animated_sprite.play(&"super_run" if is_super else &"small_run")
	_smoke_effect()

func _on_run_physics_updated(delta: float) -> void:
	_platform_movement(delta)

	if _get_horizontal_direction() == 0: state_machine.request_state(&"idle")
	if _can_jump(): state_machine.request_state(&"jump")
	if velocity.y > 0: state_machine.request_state(&"fall")

func _on_jump_state_entered() -> void:
	velocity.y = -_JUMP_FORCE
	if not Input.is_action_pressed(&"jump"): velocity.y *= _JUMP_BRAKE_FACTOR
	_coyote_clock = 0.0
	_jump_buffer_clock = 0.0
	_animated_sprite.play(&"super_jump" if is_super else &"small_jump")
	_animation.play(&"stretch")
	_smoke_effect()
	_sound_effect(preload("res://assets/sounds/player_jump_sound_effect.wav"))

func _on_jump_state_physics_updated(delta: float) -> void:
	_platform_movement(delta)

	if Input.is_action_just_released(&"jump"): velocity.y *= _JUMP_BRAKE_FACTOR
	if velocity.y > 0: state_machine.request_state(&"fall")

func _on_fall_state_entered() -> void:
	_animated_sprite.play(&"super_fall" if is_super else &"small_fall")

func _on_fall_state_physics_updated(delta: float) -> void:
	_platform_movement(delta)

	if is_on_floor(): state_machine.request_state(&"idle" if _get_horizontal_direction() == 0 else &"run")
	if _can_jump(): state_machine.request_state(&"jump")

func _on_swin_idle_state_entered() -> void:
	_animated_sprite.play(&"super_swin_idle" if is_super else &"small_swin_idle")

func _on_swin_idle_state_physics_updated(delta: float) -> void:
	velocity = velocity.lerp(Vector2.ZERO, _SPEED_DAMPING * delta)

	if _get_horizontal_direction() != 0 or _get_vertical_direction() != 0:
		state_machine.request_state(&"swin_move")

func _on_swin_move_state_entered() -> void:
	_animated_sprite.play(&"super_swin_move" if is_super else &"small_swin_move")

func _on_swin_move_state_physics_updated(delta: float) -> void:
	_top_down_movement(delta)

	if _get_horizontal_direction() == 0 and _get_vertical_direction() == 0:
		state_machine.request_state(&"swin_idle")

func _on_transform_state_entered() -> void:
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	velocity = Vector2.ZERO
	is_super = not is_super
	transformed.emit(is_super)

	if is_super:
		_animated_sprite.play_backwards(&"transform")
	else:
		_animated_sprite.play(&"transform")

	await _animated_sprite.animation_finished
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_INHERIT
	state_machine.request_state(&"idle")

	if not is_super:
		var tweem := create_tween().set_loops(25)
		tweem.tween_interval(0.05)
		tweem.tween_callback(_animated_sprite.set_modulate.bind(Color.TRANSPARENT))
		tweem.tween_interval(0.05)
		tweem.tween_callback(_animated_sprite.set_modulate.bind(Color.WHITE))

func _on_dead_freeze_state_entered() -> void:
	get_tree().paused = true

	# Configure player death.
	process_mode = Node.PROCESS_MODE_ALWAYS
	collision_layer = 0
	collision_mask = 0
	velocity = Vector2.ZERO
	z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	_animated_sprite.play(&"dead")
	_animated_sprite.pause()
	_sound_effect(preload("res://assets/sounds/player_dead_sound_effect.wav"))

	# Wait for the timer and the real state of death begins.
	await get_tree().create_timer(_DEAD_FREEZE_TIME).timeout
	state_machine.request_state(&"dead")

func _on_dead_state_entered() -> void:
	_animated_sprite.play(&"dead")
	velocity.y = -_DEAD_KNOCKBACK

func _on_dead_state_physics_updated(delta: float) -> void:
	velocity.y += _DEAD_GRAVITY_FORCE * delta

	# Emit died signal when the player disappears from the screen.
	if global_position.y > get_viewport_rect().size.y:
		if not is_dead:
			is_dead = true

			await _audio_stream.finished
			died.emit()
			queue_free()

#endregion
