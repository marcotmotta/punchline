extends Node3D

@export var root_scene_node: Node3D
@export var main_camera: Camera3D
@export var awaiting_enemies_node: Node3D

func _ready():
	pass

func _process(delta):
	var release_boundary = true

	for child in awaiting_enemies_node.get_children():
		if child.is_in_group('enemy'):
			release_boundary = false
			break

	if release_boundary:
		camera_smooth_change($Camera3D, main_camera)

		$StaticBody3D2/CollisionShape3D.set_deferred('disabled', true)

		set_process(false)

func _on_area_3d_body_entered(body):
	if body.is_in_group('player'):
		$Area3D.set_deferred('monitoring', false)
		$StaticBody3D1/CollisionShape3D.set_deferred('disabled', false)
		$StaticBody3D2/CollisionShape3D.set_deferred('disabled', false)

		camera_smooth_change(main_camera, $Camera3D)

		await get_tree().create_timer(1).timeout 

		for child in awaiting_enemies_node.get_children():
			child.start()

func camera_smooth_change(from, to):
	var cam = Camera3D.new()

	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = from.size
	cam.global_position = from.global_position
	cam.rotation = from.rotation

	root_scene_node.add_child(cam)
	cam.current = true

	var camera_tween = create_tween()
	camera_tween.tween_property(cam, 'position', to.global_position, 1).set_trans(Tween.TRANS_SINE)
	camera_tween.tween_callback(camera_tween_callback.bind(to))

func camera_tween_callback(to):
	to.current = true
