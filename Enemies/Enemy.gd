extends CharacterBody3D

enum {
	IDLE,
	RUNNING,
	ATTACKING,
	HURT
}

var state = IDLE

@export var target : CharacterBody3D

func _ready():
	randomize()
	set_state(RUNNING)

func _physics_process(delta):
	match state:
		IDLE:
			pass

		RUNNING:
			if target:
				move_to_target()

		ATTACKING:
			pass

		HURT:
			pass

func set_state(new_state):
	state = new_state

	match state:
		IDLE:
			#$AnimationPlayer.play('Idle')
			pass

		RUNNING:
			#$AnimationPlayer.play('Walk')
			pass

		ATTACKING:
			pass

		HURT:
			pass

func move_to_target():
	var direction = Vector3.ZERO

	direction = (target.global_position - global_position).normalized()

	velocity.x = direction.x * 2
	velocity.z = direction.z * 2 * 2
	velocity.y = 0

	move_and_slide()
