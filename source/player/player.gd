class_name Player extends CharacterBody2D

@onready var _sprite: Sprite2D = $Sprite

var speed := 100.0
var damping := 10.0
var direction := 1
var jump_force := 250.0

func _physics_process(delta: float) -> void:
	# Add horizontal movement.
	var movement := Input.get_axis(&"move_left", &"move_right") as int
	velocity.x = lerp(velocity.x, movement * speed, damping * delta)
	if movement != 0: direction = movement

	# Change the sprite direction.
	_sprite.flip_h = direction == -1

	# Jump and gravity logic.
	if is_on_floor() and Input.is_action_just_pressed(&"jump"):
		velocity.y = -jump_force
	else:
		velocity.y += ProjectSettings.get_setting(&"physics/2d/default_gravity") * delta

	move_and_slide()
