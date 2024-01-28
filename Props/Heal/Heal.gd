extends Area3D

@export var heal_particles_scene = preload("res://Props/Heal/HealParticles.tscn")

var pos

func _ready():
	if pos:
		global_position = pos

func _on_area_entered(area):
	if area is HitboxComponent:
		if area.get_parent().is_in_group('player'):
			var hitbox:HitboxComponent = area
			hitbox.heal(30)
			var heal_particles = heal_particles_scene.instantiate()
			heal_particles.pos = global_position
			get_parent().add_child(heal_particles)
			queue_free()

func _on_timer_timeout():
	$CollisionShape3D.disabled = false
