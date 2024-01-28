extends Node3D
class_name HealthComponent

@export var MAX_HEALTH := 100.0
var health : float

func _ready() -> void:
	health = MAX_HEALTH

func take_damage(damage: float, is_big_hit: bool) -> void:
	health -= damage

	if health <= 0:
		get_parent().set_state_dead()
	elif is_big_hit:
		get_parent().set_state_big_hurt()
	else:
		get_parent().set_state_hurt()
