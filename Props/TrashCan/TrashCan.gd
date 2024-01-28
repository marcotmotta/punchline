extends Area3D

@export var textures: Array[Texture]
@export var hits_to_destroy: int

@onready var material = $MeshInstance3D.get_active_material(0)
var hits_taken = 0

func _ready():
	if len(textures) > 0:
		material.albedo_texture = textures[0]

func take_hit():
	material.albedo_texture = textures[2 * hits_taken + 1]

	await get_tree().create_timer(0.15).timeout

	if hits_taken + 1 == hits_to_destroy:
		queue_free()
		return

	material.albedo_texture = textures[2 * hits_taken + 2]
	hits_taken = min(hits_taken + 1, hits_to_destroy)
