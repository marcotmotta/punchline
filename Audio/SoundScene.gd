extends AudioStreamPlayer3D

var pos

func _ready():
	if pos:
		global_position = pos
