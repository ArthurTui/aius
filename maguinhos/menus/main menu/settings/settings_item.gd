extends Control


func _on_SettingsItem_focus_entered():
	$FocusLabel.show()


func _on_SettingsItem_focus_exited():
	$FocusLabel.hide()
