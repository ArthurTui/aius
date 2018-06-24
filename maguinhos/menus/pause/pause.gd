extends "res://menus/popup.gd"

func _ready():
	if $Tween.is_active():
		yield($Tween, "tween_completed")
	$Popup/Buttons/Resume.grab_focus()
	printt(rect_position)


func _on_Resume_pressed():
	for btn in $Popup/Buttons.get_children():
		btn.focus_mode = FOCUS_NONE
	exit()
	yield($Tween, "tween_completed")
	get_tree().paused = false


func _on_Quit_pressed():
	$Tween.stop_all()
	$Tween.interpolate_property($Fade, "color", $Fade.color, Color(0, 0, 0, 1),
		.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	
	yield($Tween, "tween_completed")
	bgm.switch(bgm.menu)
	get_tree().paused = false
	get_tree().change_scene("res://menus/character select/CSS.tscn")
