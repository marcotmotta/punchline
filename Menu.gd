extends Control

func _on_bt_play_button_down():
	get_tree().change_scene_to_file("res://Main.tscn")

func _on_bt_credits_button_down():
	get_tree().change_scene_to_file("res://CreditsScreen.tscn")

func _on_bt_exit_button_down():
	get_tree().quit()

func _on_bt_back_to_menu_button_down():
	get_tree().change_scene_to_file("res://StartMenu.tscn")
