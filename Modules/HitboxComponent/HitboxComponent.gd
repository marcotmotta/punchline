extends Area3D
class_name HitboxComponent

@export var health_component: HealthComponent

func take_hit(damage: float, is_big_hit: bool) -> void:
	if health_component:
		health_component.take_damage(damage, is_big_hit)

func heal(amount: float) -> void:
	if health_component:
		health_component.heal(amount)
