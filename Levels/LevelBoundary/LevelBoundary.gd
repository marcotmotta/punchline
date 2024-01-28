extends Node3D

@export var trigger_stride: float
@export var boundary_stride: float
@export var root_scene_node: Node3D
@export var main_camera: Camera3D
@export var fixed_camera: Camera3D
@export var fixed_camera_position: Vector3

func _ready():	
	$Area3D.position.x += trigger_stride
	$StaticBody3D2.position.x += boundary_stride

func _on_area_3d_body_entered(body):
	if body.is_in_group('player'):
		$StaticBody3D1/CollisionShape3D.set_deferred('disabled', false)
		$StaticBody3D2/CollisionShape3D.set_deferred('disabled', false)

		fixed_camera.position = fixed_camera_position
		camera_smooth_change(main_camera, fixed_camera)
		
		$Area3D.set_deferred('monitoring', false)

func camera_smooth_change(from, to):
	var cam = Camera3D.new()

	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = from.size
	cam.position = from.position
	cam.rotation = from.rotation

	root_scene_node.add_child(cam)
	cam.current = true

	var camera_tween = create_tween()
	camera_tween.tween_property(cam, 'position', to.global_position, 1).set_trans(Tween.TRANS_SINE)
	camera_tween.tween_callback(camera_tween_callback.bind(to))

func camera_tween_callback(to):
	to.current = true

func disable_boundary():
	$StaticBody3D2/CollisionShape3D.set_deferred('disabled', true)

	camera_smooth_change(fixed_camera, main_camera)
