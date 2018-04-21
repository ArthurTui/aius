extends Node2D

var positions = [Vector2(200, 300), Vector2(800, 300), Vector2(510, 100), Vector2(510, 500)]

var char_scn = preload("res://characters/character.tscn")

var living = []

func _ready():
	pass

func _process(delta):
	pass

func start(active_players, selected_characters):
	# which ports are living
	for key in active_players.keys():
		var player = active_players[key]
		living.append(player)
		
		# creates a character and sets its skin and position
		var char_inst = char_scn.instance()
		char_inst.set_name(str("Character", player))
		char_inst.get_node("sprite").set_animation(selected_characters[player - 1])
		char_inst.position = positions[player - 1]
		
		add_child(char_inst)
	set_process(true)