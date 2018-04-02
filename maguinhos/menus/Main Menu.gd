extends Control


var selected = -1


func _on_Play_pressed():
	get_tree().change_scene("res://stages/test_stage.tscn")


func _on_Quit_pressed():
	get_tree().quit()