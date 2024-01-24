extends CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):

	var input_dir = Input.get_vector("a", "d", "s", "w")

	velocity.x = input_dir.x * 10
	velocity.z = -input_dir.y * 10
	velocity.y = 0

	if velocity:
		look_at(global_position - velocity.normalized())
		$AnimationPlayer.play('Walk')
	else:
		$AnimationPlayer.play('Idle')

	move_and_slide()
