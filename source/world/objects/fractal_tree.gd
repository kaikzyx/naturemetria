@tool
class_name FractalTree extends Node2D

@export_tool_button(&"Redraw") var redraw_action = func() -> void:
	_actual_branch_angle_deg = branch_angle_deg
	queue_redraw()

@export var initial_length := 24.0
@export_range(1, 12) var depth_max := 12
@export_range(1, 12) var leaf_depth := 5
@export_range(0.0, 90.0) var branch_angle_deg := 25.0
@export_range(0.1, 1.0) var length_scale := 0.8
@export_range(1.0, 20.0) var thickness_start := 8.0
@export_range(0.1, 1.0) var thickness_scale := 0.9

var _outline_thickness := 2.0
var _actual_branch_angle_deg := branch_angle_deg
var _color_trunk: Color = Color(&"885818")
var _color_leaf_light: Color = Color(&"88a000")
var _color_leaf_shadow: Color = Color(&"007848")

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		_actual_branch_angle_deg = branch_angle_deg + sin(Time.get_ticks_usec() * 1e-6)
		queue_redraw()

func _draw() -> void:
	_draw_branch(Vector2(0.0, 8.0), initial_length, -90.0, depth_max, thickness_start)

func _draw_branch(start: Vector2, length: float, angle_deg: float, depth: int, thickness: float) -> void:
	if depth == 0: return

	var rad := deg_to_rad(angle_deg)
	var end := start + Vector2(cos(rad), sin(rad)) * length

	# Draw the outline a little thicker.
	draw_line(start, end, Color.BLACK,  thickness + _outline_thickness)

	# Draw the leaf or branch over the outline.
	var color: Color

	if depth > leaf_depth:
		color = _color_trunk 
	else:
		color = _color_leaf_light if depth % 2 == 1 else _color_leaf_shadow

	draw_line(start, end, color, thickness)

	var new_depth := depth - 1
	var new_length := length * length_scale
	var new_thickness := thickness * thickness_scale

	_draw_branch(end, new_length, angle_deg - _actual_branch_angle_deg, new_depth, new_thickness)
	_draw_branch(end, new_length, angle_deg + _actual_branch_angle_deg, new_depth, new_thickness)
