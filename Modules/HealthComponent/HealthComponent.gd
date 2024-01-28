extends Node3D
class_name HealthComponent

@export var MAX_HEALTH := 100.0
var health : float

@export var animation_player: AnimationPlayer
@export var hit_animation: String
@export var big_hit_animation: String
@export var dying_animation: String

func _ready() -> void:
	health = MAX_HEALTH

func take_damage(damage: float, is_big_hit: bool) -> void:
	health -= damage

	if health <= 0:
		animation_player.play(dying_animation)
	elif is_big_hit:
		animation_player.play(big_hit_animation)
	else:
		animation_player.play(hit_animation)
