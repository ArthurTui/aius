extends "res://menus/popup.gd"

func _ready():
	$Popup/Back.grab_focus()


func _on_Back_pressed():
	$Popup/Back.focus_mode = FOCUS_NONE
	exit()
