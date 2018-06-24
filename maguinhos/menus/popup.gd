extends ColorRect

const ENTER_DURATION = .5
const EXIT_DURATION = .5

func _ready():
	$Popup.rect_position.y -= 1080
	$Tween.interpolate_property($Popup, "rect_position", $Popup.rect_position,
		$Popup.rect_position + Vector2(0, 1080), ENTER_DURATION,
		Tween.TRANS_BACK, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "color", color, Color(0, 0, 0, .7),
		ENTER_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	yield($Tween, "tween_completed")


func exit():
	$Tween.stop_all()
	$Tween.interpolate_property($Popup, "rect_position", $Popup.rect_position,
		$Popup.rect_position + Vector2(0, 1080), EXIT_DURATION,
		Tween.TRANS_BACK, Tween.EASE_IN)
	$Tween.interpolate_property(self, "color", color, Color(0, 0, 0, 0),
		EXIT_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	yield($Tween, "tween_completed")
	queue_free()