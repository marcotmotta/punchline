extends Node3D

func _process(delta):
	#if $Player.position.x >= $Camera3D.position.x:
	$Camera3D.position.x = $Player.position.x
