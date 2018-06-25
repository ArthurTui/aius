extends Control

const TIME = 1

signal go

func _ready():
	$Tween.interpolate_property($Ready, "modulate", Color(1, 1, 1, 0),
		Color(1, 1, 1, 1), .5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	
	yield($Tween, "tween_completed")
	
	$SFX_Ready.play()
	$Tween.interpolate_property($Ready/TextureProgress, "value", 100, 0, TIME,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	
	yield($Tween, "tween_completed")
	
	emit_signal("go")
	$SFX_Go.play()
	$Go/AnimationPlayer.play("entry")
	$Tween.interpolate_property($Ready, "modulate", Color(1, 1, 1, 1),
		Color(1, 1, 1, 0), .1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	
	pass
