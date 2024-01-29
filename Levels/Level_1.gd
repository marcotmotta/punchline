extends Node3D

func _on_audio_stream_player_finished():
	$AudioStreamPlayer2.playing = true

func _on_area_3d_body_entered(body):
	if body.is_in_group('player'):
		$AudioStreamPlayer2.volume_db = -20
		await get_tree().create_timer(1.5).timeout
		$AudioStreamPlayer2.volume_db = -30
		await get_tree().create_timer(1.5).timeout
		$AudioStreamPlayer2.playing = false
		await get_tree().create_timer(1.5).timeout
		$AudioStreamPlayer3.playing = true
