extends Area3D

var pos
var direction
var speed = 10

func _ready() -> void:
	if pos:
		global_position = pos

func _process(delta) -> void:
	global_position += direction * speed * delta

func _on_area_entered(area):
	pass # Replace with function body.
