extends CanvasLayer

@onready var _parallax: Node2D = $Parallax
@onready var _logo: Sprite2D = $Logo
@onready var _start_label: Label = $StartLabel

const _PARALLAX_SCROLL_SPEED := 500.0
const _3D_EFFECT_MAX_ROTATION := 30.0
const _3D_EFFECT_RETURN_DAMPING := 10.0

func _ready() -> void:
	# Start label pulse effect.
	var tween := create_tween().set_loops()
	tween.tween_property(_start_label, ^"modulate:a", 0.0, 0)
	tween.tween_interval(0.25)
	tween.tween_property(_start_label, ^"modulate:a", 1.0, 0)
	tween.tween_interval(0.5)

func _process(delta: float) -> void:
	var mouse := get_viewport().get_mouse_position()

	# Make the 3d hover effect with mouse.
	var center: Vector2 = get_viewport().size / 2
	var difference := mouse - center
	var target_y_rot: float = clamp(difference.x / center.x, -1.0, 1.0) * _3D_EFFECT_MAX_ROTATION
	var target_x_rot: float = -clamp(difference.y / center.y, -1.0, 1.0) * _3D_EFFECT_MAX_ROTATION
	var current_y_rot: float = _logo.material.get_shader_parameter("y_rot")
	var current_x_rot: float = _logo.material.get_shader_parameter("x_rot")
	var new_y_rot: float = lerp(current_y_rot, target_y_rot, _3D_EFFECT_RETURN_DAMPING * delta)
	var new_x_rot: float = lerp(current_x_rot, target_x_rot, _3D_EFFECT_RETURN_DAMPING * delta)
	_logo.material.set_shader_parameter("y_rot", new_y_rot)
	_logo.material.set_shader_parameter("x_rot", new_x_rot)

	# Make parallax move in mouse direction.
	for child in _parallax.get_children():
		if child is Parallax2D:
			if child.scroll_scale.x == 0: continue
			child.autoscroll.x = _PARALLAX_SCROLL_SPEED * child.scroll_scale.x

	# Start the game.
	if Input.is_action_just_pressed(&"start_game"):
		get_tree().paused = true
		await get_tree().create_timer(0.5).timeout
		Global.main.change_scene(&"interface/intro_ui", Main.Transition.DIAMOND, 1.5)
