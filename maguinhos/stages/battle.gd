extends Node2D

var positions = [Vector2(200, 300), Vector2(800, 300), Vector2(510, 100), Vector2(510, 500)]

var char_scn = preload("res://characters/character.tscn")

var living = []

func _ready():
	# gets the variables set in the CSS
	var a_d = player_data.active_devices
	var s_c = player_data. selected_characters
	
	# which ports are living
	for key in a_d.keys():
		var player = a_d[key]
		living.append(player)
		
		var character = s_c[player - 1]
		print(character)
		var sprite_frames = load(str("res://characters/sprites/",character,".tres"))
		
		# creates a character and sets its skin and position
		var char_inst = char_scn.instance()
		char_inst.set_name(str("Character", player))
		char_inst.get_node("sprite").set_sprite_frames(sprite_frames)
		char_inst.position = positions[player - 1]
		char_inst.controller_device = key
		
		add_child(char_inst)
	set_process(true)

func _process(delta):
	pass