extends CharacterBody3D

var is_attacking = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):

	var input_dir = Input.get_vector("left", "right", "up", "down")

	var direction = Vector3.ZERO

	if !is_attacking:
		direction.x = input_dir.x
		direction.z = -input_dir.y

		if velocity:
			look_at(global_position - velocity.normalized())
			$AnimationPlayer.play('Walk')
		else:
			$AnimationPlayer.play('Idle')

	velocity.x = direction.x * 10
	velocity.z = -direction.z * 10 * 2
	velocity.y = 0

	move_and_slide()

func _unhandled_input(event):
	if Input.is_action_just_pressed("z"):
		is_attacking = true
		$AnimationPlayer.play('Attack')

func _on_animation_player_animation_finished(anim_name):
	if anim_name == 'Attack':
		is_attacking = false
		$AnimationPlayer.play('Idle')
