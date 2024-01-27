extends Node3D

@export var projectile_scene: PackedScene

func begin_attack(target: CharacterBody3D, setState: Callable, nextState) -> void:
	if target.global_position.x < global_position.x:
		shoot(Vector3(-1, 0, 0))
	else:
		shoot(Vector3(1, 0, 0))

func shoot(direction: Vector3) -> void:
	var projectile_instance = projectile_scene.instantiate()
	projectile_instance.pos = $Marker3D.global_position
	projectile_instance.direction = direction
	#projectile_instance.damage = damage
	#projectile_instance.speed = speed
	get_parent().get_parent().add_child(projectile_instance)
