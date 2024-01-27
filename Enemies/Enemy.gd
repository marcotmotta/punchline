extends CharacterBody3D

enum States {
	IDLE,
	RUNNING,
	PATROL,
	ATTACKING,
	HURT
}

var state := States.IDLE

@export var target: CharacterBody3D

var patrol_direction: Vector3

func _ready() -> void:
	randomize()
	set_state(States.RUNNING)

func _physics_process(delta) -> void:
	match state:
		States.IDLE:
			pass

		States.RUNNING:
			if target:
				check_end_move_height()
				move_to_target_height()

		States.PATROL:
			move_to_direction(patrol_direction)

		States.ATTACKING:
			pass

		States.HURT:
			pass

func set_state(new_state: States) -> void:
	state = new_state

	match state:
		States.IDLE:
			#$AnimationPlayer.play('Idle')
			pass

		States.RUNNING:
			#$AnimationPlayer.play('Idle')
			pass

		States.PATROL:
			patrol_direction = choose_patrol_direction()
			$PatrolTimer.start()

		States.ATTACKING:
			if target.global_position.x < global_position.x:
				$RangedAttackComponent.shoot(Vector3(-1, 0, 0))
			else:
				$RangedAttackComponent.shoot(Vector3(1, 0, 0))
			set_state(States.PATROL)

		States.HURT:
			pass

func move_to_direction(patrol_direction):
	var direction = Vector3.ZERO

	direction = patrol_direction.normalized()

	velocity.x = direction.x * 5
	velocity.z = direction.z * 5 * 2
	velocity.y = 0

	move_and_slide()

func move_to_target_height() -> void:
	var direction = Vector3.ZERO

	direction = (target.global_position - global_position).normalized()

	velocity.x = 0 #direction.x * 2
	velocity.z = 5 * 2
	velocity.y = 0

	if direction.z < 0:
		velocity.z *= -1

	move_and_slide()

func check_end_move_height() -> void:
	if abs(global_position.z - target.global_position.z) <= 3:
		set_state(States.ATTACKING)

func choose_patrol_direction() -> Vector3:
	return Vector3(randi_range(-1, 1), 0, randi_range(-1, 1)).normalized()

func _on_patrol_timer_timeout():
	set_state(States.RUNNING)
