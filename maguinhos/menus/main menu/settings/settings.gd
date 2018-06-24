extends "res://menus/popup.gd"

func _ready():
	$Popup/VBox/Master.grab_focus()


func change_volume(value, max_value, bus_index):
	var volume = -80
	if value > 0:
		volume = 10 * log(value / max_value)
	AudioServer.set_bus_volume_db(bus_index, volume)
	

func _on_Master_value_changed(value):
	$Click.play()
	change_volume(value, $Popup/VBox/Master.max_value, 0)


func _on_Music_value_changed(value):
	$Click.play()
	change_volume(value, $Popup/VBox/Music.max_value, 1)


func _on_SFX_value_changed(value):
	$Click.play()
	change_volume(value, $Popup/VBox/SFX.max_value, 2)


func _on_Back_pressed():
	for item in $Popup/VBox.get_children():
		item.focus_mode = FOCUS_NONE
	exit()
