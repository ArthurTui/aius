extends "res://stages/stage.gd"

func _ready():
	positions = [Vector2(480, 480), Vector2(960, 240), Vector2(1440, 480),
		Vector2(960, 720)]
	print(positions)
	._ready()
