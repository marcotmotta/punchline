extends Node3D

func _on_audio_stream_player_finished():
	$AudioStreamPlayer2.playing = true
