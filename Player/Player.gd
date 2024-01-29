extends CharacterBody3D

# sound
var sound_scene = preload("res://Audio/SoundScene.tscn")

var attack_sound1 = preload("res://Audio/Hit_1.wav")
var attack_sound2 = preload("res://Audio/Hit_2.wav")
var attack_sound3 = preload("res://Audio/Hit_3.wav")
var attack_sound4 = preload("res://Audio/Hit_4.wav")

var hit_sounds = [attack_sound1, attack_sound2, attack_sound3, attack_sound4]

var hurt_sound = preload("res://Audio/Hurt_3.wav")

enum ATTACK_TYPE { NONE, BASIC, STRONG, RUNNING }

const WALK_SPEED_MOD = 10
const RUN_SPEED_MOD = 1.5
const RUN_DURATION_TIME = 2

var punch_damage = 15
var running_damage = 30

var is_running = false

var is_holding_an_item = false
var item_held = null

var is_attacking = false
var attack_type_performing = ATTACK_TYPE.NONE
var attack_combo = 1
var max_attack_combo = 4

var last_input_dir = Vector2.ZERO
var last_key_pressed = null

var is_hurt = false
var is_big_hurt = false

# Custom timers.
var remaining_time_to_press_key = 0
var remaining_time_to_run = 0

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	remaining_time_to_press_key = max(remaining_time_to_press_key - delta, 0)
	remaining_time_to_run = max(remaining_time_to_run - delta, 0)

	if is_running and remaining_time_to_run == 0:
		is_running = false
		last_key_pressed = null
		remaining_time_to_press_key = 0

	if is_attacking:
		$AnimationPlayer.speed_scale = 1.5
	else:
		$AnimationPlayer.speed_scale = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = Vector3.ZERO

	last_input_dir = input_dir

	if !is_hurt:
		if !is_attacking:
			direction.x = input_dir.x
			direction.z = input_dir.y

			if direction:
				if direction.x:
					look_at(global_position + Vector3(-direction.x, 0, 0))

				if is_running:
					direction.x *= RUN_SPEED_MOD
					$AnimationPlayer.play('Run')
				else:
					$AnimationPlayer.play('Walk')
			else:
				$AnimationPlayer.play('Idle')

			direction *= WALK_SPEED_MOD

		elif attack_type_performing == ATTACK_TYPE.RUNNING:
			if last_input_dir: # Need this?
				pass # direction.x = last_input_dir.x * WALK_SPEED_MOD * RUN_SPEED_MOD

		velocity.x = direction.x
		velocity.z = direction.z * 2
		velocity.y = 0

		move_and_slide()

func _unhandled_input(event):
	if Input.is_action_just_pressed("x"):
		if !is_hurt:
			if !is_running:
				if !is_attacking:
					is_attacking = true
					attack_type_performing = ATTACK_TYPE.BASIC
					$AnimationPlayer.stop()
					$AnimationPlayer.play('Combo_1')
				else:
					if attack_type_performing == ATTACK_TYPE.BASIC:
						attack_combo = min(attack_combo + 1, max_attack_combo)
			else:
				if !is_attacking:
					is_attacking = true
					attack_type_performing = ATTACK_TYPE.RUNNING
					$AnimationPlayer.stop()
					$AnimationPlayer.play('Combo_4')

	if Input.is_action_just_pressed("c"):
		if !is_hurt:
			if !is_attacking:
				is_attacking = true
				attack_type_performing = ATTACK_TYPE.STRONG
				$AnimationPlayer.stop()
				$AnimationPlayer.play('Super_Attack')

	if Input.is_action_just_pressed("z"):
		if !is_hurt:
			$ItemRangeAreaController/Area3D.monitoring = true

	if Input.is_action_just_released("z"):
		if !is_hurt:
			$ItemRangeAreaController/Area3D.monitoring = false

	if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
		if !is_hurt:
			if last_key_pressed == event.keycode and remaining_time_to_press_key > 0:
				is_running = true
				remaining_time_to_run = RUN_DURATION_TIME
			else:
				last_key_pressed = event.keycode
				remaining_time_to_press_key = 1

	if Input.is_action_just_released("left") or Input.is_action_just_released("right"):
		if !is_hurt:
			if is_running:
				is_running = false
				last_key_pressed = null
				remaining_time_to_press_key = 0
				remaining_time_to_run = 0

func _reset_attack_combo():
	is_attacking = false
	attack_type_performing = ATTACK_TYPE.NONE
	attack_combo = 1
	$AnimationPlayer.play('Idle')

func _on_animation_player_animation_finished(anim_name):
	if anim_name in ['Combo_1', 'Combo_2', 'Combo_3', 'Combo_4']:
		if attack_combo > 1:
			match anim_name:
				'Combo_1':
					if attack_combo >= 2:
						$AnimationPlayer.play('Combo_2')
					else:
						_reset_attack_combo()
				'Combo_2':
					if attack_combo >= 3:
						$AnimationPlayer.play('Combo_3')
					else:
						_reset_attack_combo()
				'Combo_3':
					if attack_combo >= 4:
						$AnimationPlayer.play('Combo_4')
					else:
						_reset_attack_combo()
				_:
					_reset_attack_combo()
		else:
			_reset_attack_combo()

	if anim_name in ['Change_Attack', 'Super_Attack']:
		is_attacking = false
		attack_type_performing = ATTACK_TYPE.NONE
		$AnimationPlayer.play('Idle')

	if anim_name == 'Take_Hit' or anim_name == 'Take_Big_Hit':
		is_hurt = false
		_reset_attack_combo()

func _on_area_3d_body_entered(body):
	if body.is_in_group('item') and not is_holding_an_item:
		is_holding_an_item = true
		item_held = body

func set_state_hurt():
	is_hurt = true
	$AnimationPlayer.play('Take_Hit', 0)

	var sound_instance = sound_scene.instantiate()
	sound_instance.stream = hurt_sound
	sound_instance.pos = global_position
	get_parent().add_child(sound_instance)

func set_state_big_hurt():
	is_hurt = true
	$AnimationPlayer.play('Take_Big_Hit', 0)

	var sound_instance = sound_scene.instantiate()
	sound_instance.stream = hurt_sound
	sound_instance.pos = global_position
	get_parent().add_child(sound_instance)

func set_state_dead():
	is_hurt = true

func _on_area_3d_area_entered(area):
	if area is HitboxComponent:
		if area.get_parent().is_in_group('enemy'):
			var hitbox:HitboxComponent = area

			var sound_instance = sound_scene.instantiate()
			hit_sounds.shuffle()
			sound_instance.stream = hit_sounds.front()
			sound_instance.pos = global_position
			get_parent().add_child(sound_instance)

			match attack_type_performing:
				ATTACK_TYPE.BASIC:
					hitbox.take_hit(punch_damage, false)
				ATTACK_TYPE.STRONG:
					hitbox.take_hit(punch_damage, true)
				ATTACK_TYPE.RUNNING:
					hitbox.take_hit(running_damage, true)
	elif area.is_in_group('prop'):
		area.take_hit()
