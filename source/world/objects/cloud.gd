@tool
class_name Cloud extends StaticBody2D

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite
const _TWEEN_TIME := 0.1
const _STAR_KNOCKBACK := 200.0

@export var has_star: bool = false:
	set(value):
		has_star = value
		if is_instance_valid(_animated_sprite): _refresh()

func _ready() -> void:
	_refresh()

func _refresh() -> void:
	_animated_sprite.play(&"heavy" if has_star else &"light")

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Player:
		# Spawn the star power up.  
		if has_star:
			has_star = false

			var star := preload("res://source/world/objects/star.tscn").instantiate() as Star
			star.global_position = global_position - Vector2(0.0, 16.0)
			star.velocity.y = -_STAR_KNOCKBACK
			get_parent().call_deferred(&"add_child", star)

		# Animates the hit effect.
		var tween := create_tween().set_trans(Tween.TRANS_SINE)
		tween.tween_property(_animated_sprite, ^"position:y", -8, _TWEEN_TIME).as_relative().set_ease(Tween.EASE_OUT)
		tween.tween_property(_animated_sprite, ^"position:y", 8, _TWEEN_TIME).as_relative().set_ease(Tween.EASE_IN)
