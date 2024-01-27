extends Node3D

@export var projectile_scene: PackedScene

func shoot(direction) -> void:
	var projectile_instance = projectile_scene.instantiate()
	projectile_instance.pos = $Marker3D.global_position
	projectile_instance.direction = direction
	#projectile_instance.damage = damage
	#projectile_instance.speed = speed
	get_parent().get_parent().add_child(projectile_instance)
