extends CPUParticles3D

var pos

func _ready():
	if pos:
		global_position = pos
	emitting = true

func _on_timer_timeout():
	queue_free()
