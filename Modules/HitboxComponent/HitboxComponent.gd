extends Area3D

@export var health_component: HealthComponent

func take_hit(damage: float) -> void:
	if health_component:
		health_component.take_damage(damage)
