extends Node3D

func _process(delta):
	#if $Player.position.x >= $Camera3D.position.x:
	if $Player.position.x >= 2.5:
		$Camera3D.position.x = $Player.position.x
