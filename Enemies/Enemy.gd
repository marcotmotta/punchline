extends CharacterBody3D

enum States {
	IDLE,
	RUNNING,
	PATROL,
	ATTACKING,
	HURT,
	BIGHURT,
	DEAD
}

var state := States.IDLE

@export var target: CharacterBody3D
@export var type: String

var remaining_idle_time: float
var patrol_direction: Vector3

func _ready() -> void:
	randomize()
	set_state(States.RUNNING)

func _physics_process(delta) -> void:
	match state:
		States.IDLE:
			pass

		States.RUNNING:
			if type == 'ranged':
				if target:
					check_manhattan_distance_to_attack()
					move_to_target_height()
			elif type == 'melee':
				if target:
					check_manhattan_distance_to_attack(true) # Check X and Z distances.
					move_to_target()

		States.PATROL:
			move_to_direction(patrol_direction)

		States.ATTACKING:
			pass

		States.HURT:
			pass

		States.BIGHURT:
			pass

func set_state(new_state: States) -> void:
	state = new_state

	match state:
		States.IDLE:
			$AnimationPlayer.play('P_Idle')

		States.RUNNING:
			if type == 'ranged':
				$AnimationPlayer.play('P_Aiming_Walk')
			elif type == 'melee':
				$AnimationPlayer.play('P2_Walk')

		States.PATROL:
			patrol_direction = choose_patrol_direction()
			if patrol_direction == Vector3.ZERO:
				set_state(States.IDLE)
			else:
				if type == 'ranged':
					$AnimationPlayer.play('P_Aiming_Walk')
				elif type == 'melee':
					$AnimationPlayer.play('P2_Walk')
				$PatrolTimer.start()

		States.ATTACKING:
			if type == 'ranged':
				$AnimationPlayer.play('P_Throw_Pie')
			elif type == 'melee':
				$AnimationPlayer.play('P2_Melee_Attack')

		States.HURT:
			$AnimationPlayer.stop()
			if type == 'ranged':
				$AnimationPlayer.play('P_Taking_Hit')
			elif type == 'melee':
				$AnimationPlayer.play('P2_Taking_Hit')

		States.BIGHURT:
			if type == 'ranged':
				$AnimationPlayer.play('P_Taking_Big_Hit')
			elif type == 'melee':
				$AnimationPlayer.play('P2_Taking_Big_Hit')

		States.DEAD:
			if type == 'ranged':
				$AnimationPlayer.play('P_Slow_Diyng')
			elif type == 'melee':
				$AnimationPlayer.play('P2_Slow_Diyng')

func move_to_direction(patrol_direction) -> void:
	var direction = Vector3.ZERO

	direction = patrol_direction.normalized()

	if direction.x:
		look_at(global_position + Vector3(-direction.x, 0, 0))

	velocity.x = direction.x * 5
	velocity.z = direction.z * 5 * 2
	velocity.y = 0

	move_and_slide()

func move_to_target() -> void:
	var direction = Vector3.ZERO

	direction = (target.global_position - global_position).normalized()

	if direction.x:
		look_at(global_position + Vector3(-direction.x, 0, 0))

	velocity.x = direction.x * 5
	velocity.z = direction.z * 5 * 2
	velocity.y = 0

	move_and_slide()

func move_to_target_height() -> void:
	var direction = Vector3.ZERO

	direction = (target.global_position - global_position).normalized()

	if direction.x:
		look_at(global_position + Vector3(-direction.x, 0, 0))

	velocity.x = 0 # direction.x * 2
	velocity.z = 5 * 2
	velocity.y = 0

	if direction.z < 0:
		velocity.z *= -1

	move_and_slide()

func check_manhattan_distance_to_attack(check_x_axis = false) -> void:
	if !check_x_axis:
		if abs(global_position.z - target.global_position.z) <= 3:
			$AnimationPlayer.stop()
			set_state(States.ATTACKING)
	else:
		if abs(global_position.z - target.global_position.z) <= 3 and abs(global_position.x - target.global_position.x) <= 3:
			$AnimationPlayer.stop()
			set_state(States.ATTACKING)

func choose_patrol_direction() -> Vector3:
	return Vector3(randi_range(-1, 1), 0, randi_range(-1, 1)).normalized()

func _on_patrol_timer_timeout():
	if state == States.PATROL:
		set_state(States.RUNNING)

# Called by the "P_Throw_Pie" animation.
func begin_attack():
	$RangedAttackComponent.begin_attack(target)

func set_state_hurt():
	if state != States.BIGHURT:
		set_state(States.HURT)

func set_state_big_hurt():
	set_state(States.BIGHURT)

func set_state_dead():
	set_state(States.DEAD)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == 'P_Throw_Pie' or anim_name == 'P2_Melee_Attack':
		set_state(States.PATROL)
	elif anim_name == 'P_Idle' or anim_name == 'P2_Idle':
		set_state(States.RUNNING)
	elif anim_name == 'P_Taking_Hit' or anim_name == 'P2_Taking_Hit':
		set_state(States.RUNNING)
	elif anim_name == 'P_Taking_Big_Hit' or anim_name == 'P2_Taking_Big_Hit':
		set_state(States.RUNNING)
	elif anim_name == 'P_Slow_Diyng' or anim_name == 'P2_Slow_Diyng':
		queue_free()

func _on_area_3d_area_entered(area):
	if area is HitboxComponent:
		if area.get_parent().is_in_group('player'):
			var hitbox:HitboxComponent = area
			hitbox.take_hit(10, false)
