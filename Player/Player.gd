extends CharacterBody3D

enum ATTACK_TYPE { NONE, BASIC, STRONG, RUNNING }

const WALK_SPEED_MOD = 10
const RUN_SPEED_MOD = 2
const RUN_DURATION_TIME = 2

var is_running = false

var is_holding_an_item = false
var item_held = null

var is_attacking = false
var attack_type_performing = ATTACK_TYPE.NONE
var attack_combo = 1
var max_attack_combo = 4

var last_input_dir = Vector2.ZERO
var last_key_pressed = null

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
		if !is_attacking:
			is_attacking = true
			attack_type_performing = ATTACK_TYPE.STRONG
			$AnimationPlayer.stop()
			$AnimationPlayer.play('Super_Attack')

	if Input.is_action_just_pressed("z"):
		$ItemRangeAreaController/Area3D.monitoring = true

	if Input.is_action_just_released("z"):
		$ItemRangeAreaController/Area3D.monitoring = false

	if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
		if last_key_pressed == event.keycode and remaining_time_to_press_key > 0:
			is_running = true
			remaining_time_to_run = RUN_DURATION_TIME
		else:
			last_key_pressed = event.keycode
			remaining_time_to_press_key = 1

	if Input.is_action_just_released("left") or Input.is_action_just_released("right"):
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

func _on_area_3d_body_entered_item_range(body):
	if body.is_in_group('item') and not is_holding_an_item:
		is_holding_an_item = true
		item_held = body

func _on_area_3d_area_entered(area):
	if area is HitboxComponent:
		var hitbox:HitboxComponent = area
		match attack_type_performing:
			ATTACK_TYPE.BASIC:
				hitbox.take_hit(10, false)
			ATTACK_TYPE.STRONG:
				hitbox.take_hit(10, true)
			ATTACK_TYPE.RUNNING:
				hitbox.take_hit(10, true)
