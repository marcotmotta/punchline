extends Node3D

@export var projectile_scene: PackedScene

func begin_attack(target: CharacterBody3D, target_group: String) -> void:
	if target.global_position.x < global_position.x:
		shoot(Vector3(-1, 0, 0), target_group)
	else:
		shoot(Vector3(1, 0, 0), target_group)

func shoot(direction: Vector3, target_group: String) -> void:
	var projectile_instance = projectile_scene.instantiate()
	projectile_instance.pos = $Marker3D.global_position
	projectile_instance.direction = direction
	projectile_instance.target_group = target_group
	get_parent().get_parent().add_child(projectile_instance)
