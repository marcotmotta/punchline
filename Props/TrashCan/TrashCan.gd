extends Area3D

@export var textures: Array[Texture]
@export var hits_to_destroy: int

@export var heal_scene = preload("res://Props/Heal/Heal.tscn")

@onready var material = $MeshInstance3D.get_active_material(0)
var hits_taken = 0

func _ready():
	var new_material = material.duplicate()
	material = new_material
	$MeshInstance3D.set_surface_override_material(0,new_material)

	if len(textures) > 0:
		material.albedo_texture = textures[0]

func take_hit():
	material.albedo_texture = textures[2 * hits_taken + 1]

	await get_tree().create_timer(0.15).timeout

	if hits_taken + 1 == hits_to_destroy:
		var heal = heal_scene.instantiate()
		heal.pos = global_position
		get_parent().add_child(heal)
		queue_free()
		return

	material.albedo_texture = textures[2 * hits_taken + 2]
	hits_taken = min(hits_taken + 1, hits_to_destroy)
