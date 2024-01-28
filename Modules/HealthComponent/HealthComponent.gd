extends Node3D
class_name HealthComponent

@export var MAX_HEALTH := 100.0
var health : float

func _ready() -> void:
	health = MAX_HEALTH

func _process(delta):
	if get_node_or_null("../CanvasLayer/Control/HealthBar"):
		$"../CanvasLayer/Control/HealthBar".max_value = MAX_HEALTH
		$"../CanvasLayer/Control/HealthBar".value = health

func take_damage(damage: float, is_big_hit: bool) -> void:
	if !"is_hurt" in get_parent() or !get_parent().is_hurt:
		health -= damage

		if health <= 0:
			get_parent().set_state_dead()
		elif is_big_hit:
			get_parent().set_state_big_hurt()
		else:
			get_parent().set_state_hurt()

func heal(amount: float) -> void:
		health += amount

		if health >= MAX_HEALTH:
			health = MAX_HEALTH
