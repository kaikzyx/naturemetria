extends Enemy

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var _raycasts: Node2D = $RayCasts
@onready var _wall_detector: RayCast2D = $RayCasts/WallDetector
@onready var _ground_detector: RayCast2D = $RayCasts/GroundDetector
@onready var _state_machine: StateMachine = $StateMachine

const _DEAD_TIME := 1
const _DEAD_FADE_TIME := 0.25
var speed := 500.0
var direction := 1

func _ready() -> void:
	_state_machine.start()

func _physics_process(_delta: float) -> void:
	move_and_slide()

func invert() -> void:
	direction *= -1
	_raycasts.scale.x *= -1
	_animated_sprite.flip_h = not _animated_sprite.flip_h

func kill() -> void:
	_state_machine.request_state(&"dead")

#region State machine callbacks.

func _on_patrol_state_entered() -> void:
	_animated_sprite.play(&"patrol")

func _on_patrol_state_physics_updated(delta: float) -> void:
	# Add horizontal movement.
	velocity.x = direction * speed * delta

	# Change the direction.
	if _wall_detector.is_colliding() or (is_on_floor() and not _ground_detector.is_colliding()):
		invert()

	# Gravity logic.
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting(&"physics/2d/default_gravity") * delta

func _on_dead_state_entered() -> void:
	_animated_sprite.play(&"dead")
	collision_layer = 0
	collision_mask = 0
	velocity = Vector2.ZERO

	await get_tree().create_timer(_DEAD_TIME).timeout
	
	var tween := get_tree().create_tween()
	tween.tween_property(self, ^"modulate:a", 0, _DEAD_FADE_TIME)
	tween.tween_callback(self.queue_free)

#endregion
