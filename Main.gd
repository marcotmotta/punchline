extends Node3D

func _process(delta):
	#if $Player.position.x >= $Camera3D.position.x:
	$MainCamera3D.position.x = $Player.position.x

func _unhandled_input(event):
	if Input.is_action_just_pressed("f1"):
		camera_smooth_change($MainCamera3D, $FixedCamera3D)
	if Input.is_action_just_pressed("f2"):
		camera_smooth_change($FixedCamera3D, $MainCamera3D)

func camera_smooth_change(from, to):
	var cam = Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = from.size
	cam.position = from.position
	cam.rotation = from.rotation

	add_child(cam)
	cam.current = true

	var camera_tween = create_tween()
	camera_tween.tween_property(cam, "position", to.global_position, 1).set_trans(Tween.TRANS_SINE)
	camera_tween.tween_callback(camera_tween_callback.bind(to))

func camera_tween_callback(to):
	to.current = true
