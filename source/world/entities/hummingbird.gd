extends Enemy

@onready var _state_machine: StateMachine = $StateMachine
@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite

const _SPEED: float = 5000.0
const _DEAD_GRAVITY_FORCE := 500.0
const _DEAD_INTERVAL_TIME := 0.25
const _DEAD_KNOCKBACK := 100.0
const _DEAD_ROTATION_VELOCITY := 10.0

func _ready() -> void:
	_animated_sprite.play(&"fly")
	_state_machine.start()

func _physics_process(_delta: float) -> void:
	move_and_slide()

func kill() -> void:
	_state_machine.request_state(&"dead")

func _is_inside_viewport() -> bool:
	var size := get_viewport_rect().size
	return Rect2(Global.player.global_position - size / 2, size).has_point(global_position)

func _on_idle_state_entered() -> void:
	velocity = Vector2.ZERO

func _on_idle_state_physics_updated(_delta: float) -> void:
	if _is_inside_viewport():
		_state_machine.request_state(&"move")

func _on_move_state_physics_updated(delta: float) -> void:
	velocity.x = -_SPEED * delta

	if not _is_inside_viewport():
		queue_free()

func _on_dead_state_entered() -> void:
	# Configure hummingbird death.
	collision_layer = 0
	collision_mask = 0
	velocity = Vector2(0, -_DEAD_KNOCKBACK)
	z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	_animated_sprite.pause()

func _on_dead_state_physics_updated(delta: float) -> void:
	velocity.y += _DEAD_GRAVITY_FORCE * delta
	_animated_sprite.rotate(_DEAD_ROTATION_VELOCITY * delta)

	# Free when the hummingbird disappears from the screen.
	if global_position.y > get_viewport_rect().size.y:
		await get_tree().create_timer(_DEAD_INTERVAL_TIME).timeout
		queue_free()
