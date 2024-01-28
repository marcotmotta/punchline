extends CharacterBody3D

# sound
var sound_scene = preload("res://Audio/SoundScene.tscn")

var hurt_sound1 = preload("res://Audio/Hurt_inimigo_1.wav")
var hurt_sound2 = preload("res://Audio/Hurt_inimigo_2.wav")

var hurt_sounds = [hurt_sound1, hurt_sound2]

enum States {
	IDLE,
	RUNNING,
	PATROL,
	ATTACKING,
	PRESUPER,
	SUPER,
	HURT,
	BIGHURT,
	DEAD
}

enum BossAttacks {
	MELEE,
	RANGED,
	SUPER
}

var state := States.IDLE
var awaiting = true

@export var target: CharacterBody3D
@export var type: String

var remaining_idle_time: float
var patrol_direction: Vector3

var boss_attack_type: BossAttacks
var super_attack_direction: int

func _ready() -> void:
	randomize()
	set_state(States.IDLE)

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
			elif type == 'boss':
				match boss_attack_type:
					BossAttacks.MELEE:
						pass
					BossAttacks.SUPER:
						if target:
							check_manhattan_distance_to_attack()
							move_to_target_height()
					BossAttacks.RANGED:
						if target:
							check_manhattan_distance_to_attack()
							move_to_target_height()

		States.PATROL:
			move_to_direction(patrol_direction)

		States.ATTACKING:
			pass

		States.PRESUPER:
			pass

		States.SUPER:
			if type == 'boss' and boss_attack_type == BossAttacks.SUPER:
				move_to_direction(Vector3(super_attack_direction, 0, 0), true)

		States.HURT:
			pass

		States.BIGHURT:
			pass

func set_state(new_state: States) -> void:
	state = new_state

	match state:
		States.IDLE:
			if type == 'ranged':
				$AnimationPlayer.play('P_Idle')
			elif type == 'melee':
				$AnimationPlayer.play('P2_Idle')
			elif type == 'boss':
				$SuperHitBox/SuperHitBox.disabled = true
				$AnimationPlayer.play('B_Idle')

		States.RUNNING:
			if type == 'ranged':
				$AnimationPlayer.play('P_Aiming_Walk')
			elif type == 'melee':
				$AnimationPlayer.play('P2_Walk')
			elif type == 'boss':
				boss_attack_type = choose_boss_attack_type()
				$AnimationPlayer.play('B_Walk')

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
			elif type == 'boss':
				match boss_attack_type:
					BossAttacks.MELEE:
						pass
					BossAttacks.SUPER:
						set_state(States.PRESUPER)
					BossAttacks.RANGED:
						$AnimationPlayer.play('B_Throw')

		States.PRESUPER:
			$AnimationPlayer.play_backwards('B_Idle_Meme')

		States.SUPER:
			var direction = (target.global_position - global_position).normalized()
			if direction.x > 0:
				super_attack_direction = 1
			else:
				super_attack_direction = -1
			$SuperAttack.start(3)
			$AnimationPlayer.play('B_Super_Attack')
			$SuperHitBox/SuperHitBox.disabled = false

		States.HURT:
			play_hurt_sound()
			$AnimationPlayer.stop()
			if type == 'ranged':
				$AnimationPlayer.play('P_Taking_Hit')
			elif type == 'melee':
				$AnimationPlayer.play('P2_Taking_Hit')
			elif type == 'boss':
				$AnimationPlayer.play('B_Take_Hit')

		States.BIGHURT:
			play_hurt_sound()
			if type == 'ranged':
				$AnimationPlayer.play('P_Taking_Big_Hit')
			elif type == 'melee':
				$AnimationPlayer.play('P2_Taking_Big_Hit')
			elif type == 'boss':
				$AnimationPlayer.play('B_Take_Big_Hit')

		States.DEAD:
			if type == 'ranged':
				$AnimationPlayer.play('P_Slow_Diyng')
			elif type == 'melee':
				$AnimationPlayer.play('P2_Slow_Diyng')
			elif type == 'boss':
				$AnimationPlayer.play('B_Death')

func move_to_direction(patrol_direction, is_boss_super = false) -> void:
	var direction = Vector3.ZERO

	direction = patrol_direction.normalized()

	if direction.x:
		look_at(global_position + Vector3(-direction.x, 0, 0))

	var speed = 5
	
	if is_boss_super:
		speed *= 2

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed * 2
	velocity.y = 0

	move_and_slide()

func move_to_target() -> void:
	var direction = Vector3.ZERO

	direction = (target.global_position - global_position).normalized()

	if direction.x != 0:
		look_at(global_position + Vector3(-direction.x, 0, 0))

	velocity.x = direction.x * 5
	velocity.z = direction.z * 5 * 2
	velocity.y = 0

	move_and_slide()

func move_to_target_height() -> void:
	var direction = Vector3.ZERO

	direction = (target.global_position - global_position).normalized()

	if direction.x != 0:
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

func start() -> void:
	awaiting = false
	set_state(States.RUNNING)

func _on_patrol_timer_timeout():
	if state == States.PATROL:
		set_state(States.RUNNING)

func choose_boss_attack_type():
	var array = [BossAttacks.RANGED, BossAttacks.SUPER]
	array.shuffle()
	return array.front()

# Called by the "P_Throw_Pie" and "B_Throw" animation.
func begin_attack():
	$RangedAttackComponent.begin_attack(target, 'player')

func set_state_hurt():
	if state != States.BIGHURT:
		if type != 'boss':
			set_state(States.HURT)

func set_state_big_hurt():
	if type != 'boss':
		set_state(States.BIGHURT)

func set_state_dead():
	set_state(States.DEAD)

func play_hurt_sound():
	var sound_instance = sound_scene.instantiate()
	hurt_sounds.shuffle()
	sound_instance.stream = hurt_sounds.front()
	sound_instance.pos = global_position
	get_parent().add_child(sound_instance)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == 'P_Throw_Pie' or anim_name == 'P2_Melee_Attack':
		set_state(States.PATROL)
	elif anim_name == 'B_Throw':
		set_state(States.RUNNING)
	elif anim_name == 'B_Idle_Meme':
		set_state(States.SUPER)
	elif anim_name == 'P_Idle' or anim_name == 'P2_Idle' or anim_name == 'B_Idle':
		set_state(States.RUNNING if !awaiting else States.IDLE)
	elif anim_name == 'P_Taking_Hit' or anim_name == 'P2_Taking_Hit' or anim_name == 'B_Take_Hit':
		set_state(States.RUNNING)
	elif anim_name == 'P_Taking_Big_Hit' or anim_name == 'P2_Taking_Big_Hit' or anim_name == 'B_Take_Big_Hit':
		set_state(States.RUNNING)
	elif anim_name == 'P_Slow_Diyng' or anim_name == 'P2_Slow_Diyng' or anim_name == 'B_Death':
		queue_free()

func _on_area_3d_area_entered(area):
	if area.get_parent().is_in_group('player'):
		if area is HitboxComponent:
			var hitbox:HitboxComponent = area
			hitbox.take_hit(10, false)

func _on_super_attack_timeout():
	$SuperHitBox/SuperHitBox.disabled = true
	set_state(States.IDLE)

func _on_super_hit_box_area_entered(area):
	if area is HitboxComponent:
		if area.get_parent().is_in_group('player'):
			var hitbox:HitboxComponent = area
			hitbox.take_hit(15, true)
			$SuperHitBox/SuperHitBox.disabled = true
			$SuperAttack.stop()
			$SuperAttack.start(0.5)
