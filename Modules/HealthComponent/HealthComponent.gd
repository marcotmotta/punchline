extends Node3D
class_name HealthComponent

@export var MAX_HEALTH := 100.0
var health : float

func _ready() -> void:
	health = MAX_HEALTH

func take_damage(damage: float) -> void:
	health -= damage

	if health <= 0:
		get_parent().queue_free()
