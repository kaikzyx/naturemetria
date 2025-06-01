class_name Snail extends CharacterBody2D

@onready var _sprite: Sprite2D = $Sprite
@onready var _raycasts: Node2D = $RayCasts
@onready var _wall_detector: RayCast2D = $RayCasts/WallDetector
@onready var _ground_detector: RayCast2D = $RayCasts/GroundDetector

var speed := 500.0
var direction := 1

func _physics_process(delta: float) -> void:
	# Add horizontal movement.
	velocity.x = direction * speed * delta

	# Change the direction.
	if _wall_detector.is_colliding() or (is_on_floor() and not _ground_detector.is_colliding()):
		invert()

	# Gravity logic.
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting(&"physics/2d/default_gravity") * delta

	move_and_slide()

func invert() -> void:
	direction *= -1
	_raycasts.scale.x *= -1
	_sprite.flip_h = not _sprite.flip_h
