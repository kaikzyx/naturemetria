class_name Star extends CharacterBody2D

@onready var _wall_detector: RayCast2D = $WallDetector

const _SPEED := 25.0

func _ready() -> void:
	velocity.x = _SPEED

func _physics_process(delta: float) -> void:
	# Reverse direction if colliding with wall.
	if _wall_detector.is_colliding():
		_wall_detector.target_position.x *= -1
		velocity.x *= -1

	# Gravity logic.
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting(&"physics/2d/default_gravity") * delta

	move_and_slide()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Player:
		body.consume()
		queue_free()
