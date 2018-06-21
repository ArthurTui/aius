extends Node2D

export (PoolVector2Array) var positions

var char_scn = preload("res://characters/character.tscn")
var testing = true

var living = 0

func _ready():
	# gets the variables set in the CSS
	var a_d = player_data.active_devices
	var s_c = player_data.selected_characters
	
	if a_d == null:
		return
	# which ports are living
	print(a_d)
	for key in a_d.keys():
		var player = a_d[key]
		living += 1
		
		var character = s_c[player - 1]
		var sprite_frames = load(str("res://characters/sprites/",character,".tres"))
		
		# creates a character and sets its skin, position and other variables
		var char_inst = char_scn.instance()
		char_inst.set_name(str("Character", player))
		char_inst.get_node("sprite").set_sprite_frames(sprite_frames)
		char_inst.connect("death", self, "another_one_bites_the_dust")
		char_inst.character_name = character
		char_inst.position = positions[player - 1]
		char_inst.controller_device = key
		
		$YSort.add_child(char_inst)


func _process(delta):
	check_end_condition()


# Called by signals
func shake_screen(s):
	$ScreenShake.add_shake(s)


func another_one_bites_the_dust():
	living -= 1


func check_end_condition():
	if living <= 1:
		set_process(false)
		$WinTimer.start()
		for node in $YSort.get_children():
			if node.is_in_group("Player"):
				$HUD/Winner.set_text(str(node.character_name, " wins!!"))
				$HUD/Winner.show()
				$HUD/Winner/Rainbow.play("rainbow")


func _on_WinTimer_timeout():
	for node in $YSort.get_children():
		if node.is_in_group("Player"):
			node.queue_free()
	get_tree().change_scene("res://menus/CSS.tscn")
