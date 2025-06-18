class_name WordUI extends CanvasLayer

@onready var _score: Control = $Score
@onready var _score_label: Label = $Score/ScoreLabel
@onready var _power_up_panel: Sprite2D = $PowerUpPanel

var _total_score := 1
var _previous_score := 0

func next_score(coord: Vector2) -> void:
	var next := _previous_score + _total_score
	_previous_score = _total_score
	_total_score = next

	_score_label.text = &"x " + str(_total_score)

	# Creates a floating score for decoration.
	var difference := _total_score - _previous_score
	var instance := preload("res://source/interface/score_effect_ui.tscn").instantiate() as Label
	instance.text = &"+" + str(1 if difference == 0 else difference)
	instance.global_position = coord
	Global.main.current.add_child(instance)

	# Effect on score when receiving points.
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_callback(func() -> void: _score.pivot_offset = _score.size / 2)
	tween.tween_property(_score, ^"scale", Vector2.ONE * 1.5, 0.1)
	tween.tween_property(_score, ^"scale", Vector2.ONE, 0.1)

func refresh_power_up_panel(enable: bool) -> void:
	# Effect on the power up panel when receiving or losing power.
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_callback(func() -> void: _power_up_panel.frame = int(enable))
	tween.tween_property(_power_up_panel, ^"scale", Vector2.ONE * 1.5, 0.1)
	tween.tween_property(_power_up_panel, ^"scale", Vector2.ONE, 0.1)
