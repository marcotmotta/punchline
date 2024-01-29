extends Area3D

var pos
var direction
var speed = 15
var target_group
var hit_damage = 10

func _ready() -> void:
	if pos:
		global_position = pos
	look_at(global_position + direction)

func _process(delta) -> void:
	global_position += direction * speed * delta

func _on_area_entered(area):
	if area is HitboxComponent:
		if area.get_parent().is_in_group(target_group):
			var hitbox:HitboxComponent = area
			hitbox.take_hit(hit_damage, false)
			queue_free()

func _on_timer_timeout():
	queue_free()
