extends Node2D

var positions = [Vector2(200, 300), Vector2(800, 300), Vector2(510, 100), Vector2(510, 500)]

var char_scn = preload("res://characters/character.tscn")
var pause_scn = preload("res://menus/pause_screen.tscn")

var living = 0

func _ready():
	# gets the variables set in the CSS
	var a_d = player_data.active_devices
	var s_c = player_data. selected_characters
	
	$winner.hide()
	
	# which ports are living
	for key in a_d.keys():
		var player = a_d[key]
		living += 1
		
		var character = s_c[player - 1]
		var sprite_frames = load(str("res://characters/sprites/",character,".tres"))
		
		# creates a character and sets its skin, position and other variables
		var char_inst = char_scn.instance()
		char_inst.set_name(str("Character", player))
		char_inst.get_node("sprite").set_sprite_frames(sprite_frames)
		char_inst.connect("death", self, "anotherOneBitesTheDust")
		char_inst.character_name = character
		char_inst.position = positions[player - 1]
		char_inst.controller_device = key
		
		add_child(char_inst)
	# we instance the pause scene last so that is stays above everything and everyone
	add_child(pause_scn.instance())
		
	set_process(true)


func _process(delta):
	check_end_condition()


func anotherOneBitesTheDust():
	living -= 1


func check_end_condition():
	if living <= 1:
		set_process(false)
		$win_timer.start()
		for node in get_children():
			if node.is_in_group("Player"):
				$winner.set_text(str(node.character_name, " wins!!"))
				$winner.show()
				$winner/rainbow.play("rainbow")


func _on_win_timer_timeout():
	for node in get_children():
		if node.is_in_group("Player"):
			node.queue_free()
	get_tree().change_scene("res://menus/CSS.tscn")
