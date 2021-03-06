extends Node2D

export (PoolVector2Array) var positions
export (AudioStream) var stage_bgm

var char_scn = preload("res://characters/character.tscn")
var testing = true

var living = 0

func _ready():
	# change bgm
	bgm.switch(stage_bgm)
	
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
		# starting element
		if character.begins_with("char1"):
			char_inst.change_element(2)
		char_inst.set_name(str("Character", player))
		char_inst.get_node("sprite").set_sprite_frames(sprite_frames)
		char_inst.connect("death", self, "another_one_bites_the_dust")
		char_inst.character_name = character
		char_inst.position = positions[player - 1]
		char_inst.controller_device = key
		
		$YSort.add_child(char_inst)


func _process(delta):
	check_end_condition()

func _input(event):
	if Input.is_action_just_pressed("pause"):
		print("pause")
		var pause_scn = load("res://menus/pause/Pause.tscn")
		get_tree().paused = true
		add_child(pause_scn.instance())


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
	bgm.switch(bgm.menu)
	get_tree().change_scene("res://menus/character select/CSS.tscn")


func _on_Countdown_go():
	for child in $YSort.get_children():
		if child.is_in_group("Player"):
			child.has_control = true
