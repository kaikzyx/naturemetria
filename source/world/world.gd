extends Node2D

@onready var _word_ui: WordUI = $WordUI
@onready var _paticles: GPUParticles2D = $LeafParticles

const _KILLED_SCORE_LABEL_OFFSET := Vector2(0, -16.0)
const _CONSUMED_SCORE_LABEL_OFFSET := Vector2(0, -32.0)

func _ready() -> void:
	var size := get_viewport_rect().size
	(_paticles.process_material as ParticleProcessMaterial).emission_box_extents = Vector3(size.x, size.y, 0.0)

func _process(_delta: float) -> void:
	_paticles.global_position = get_viewport().get_camera_2d().global_position

func _on_main_ready(main: Main) -> void:
	main.interface.add_child(_word_ui)

func _on_player_died() -> void:
	Global.main.change_scene(&"world/world", Main.Transition.CIRCLE)

func _on_player_transformed(status: bool) -> void:
	if is_instance_valid(_word_ui):
		_word_ui.refresh_power_up_panel(status)

func _on_player_killed() -> void:
	if is_instance_valid(_word_ui):
		_word_ui.add_score(100, Global.player.global_position + _KILLED_SCORE_LABEL_OFFSET)

func _on_player_consumed() -> void:
	if is_instance_valid(_word_ui):
		_word_ui.add_score(250, Global.player.global_position + _CONSUMED_SCORE_LABEL_OFFSET)
