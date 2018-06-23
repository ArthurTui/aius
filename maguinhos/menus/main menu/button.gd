extends Button

const FOCUS_X = 100
const SPEED = 300

func _on_MainMenuButton_focus_entered():
	# Position animation
	var d = (FOCUS_X - rect_position.x) / SPEED
	$Tween.stop_all()
	$Tween.interpolate_property(self, "rect_position", rect_position,
		Vector2(FOCUS_X, rect_position.y), d, Tween.TRANS_BACK, Tween.EASE_OUT)
	$Tween.start()
	
	# Label
#	$NormalLabel.hide()
	$FocusLabel.show()


func _on_MainMenuButton_focus_exited():
	# Position animation
	var d = rect_position.x / SPEED
	$Tween.stop_all()
	$Tween.interpolate_property(self, "rect_position", rect_position,
		Vector2(0, rect_position.y), d, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()
	
	# Label
#	$NormalLabel.show()
	$FocusLabel.hide()
