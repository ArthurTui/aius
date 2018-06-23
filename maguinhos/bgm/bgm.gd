extends AudioStreamPlayer

const menu = preload("res://bgm/The Rush.ogg")
const forest = preload("res://bgm/mythica.ogg")
const temple = preload("res://bgm/The 9th Circle V2.ogg")

func fade_out(duration=1.0):
	$Tween.stop_all()
	$Tween.interpolate_property(self, "volume_db", volume_db, -80, duration,
		Tween.TRANS_EXPO, Tween.EASE_IN)
	$Tween.start()


func switch(new_bgm):
#	if $Tween.is_active():
#		yield($Tween, "tween_completed")
	volume_db = 0
	stream = new_bgm
	play()