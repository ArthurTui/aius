extends Control

const KB_CUSTOM_ID = 100 # would be preferrable not to change this number

var active_devices = {} # which device controls which player
var selected_characters = [null,null,null,null]
var available_characters = ["skeleton", "broleton", "sealeton", "bloodyskel"]

var active_players = 0 # number of active players
var ready_players = [] # which players are ready

var started = false # has the game started?



func _ready():
	set_process_input(true)


func _input(event):
	if not started:
		# detects a keyboard event and changes id so that the first
		# controller and the keyboard don't overlap inputs
		if event is InputEventKey:
			event.device = KB_CUSTOM_ID
		
		if Input.is_action_just_pressed("pause"):
			player_start(event.device)
		
		
		elif Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left"):
			player_change_char(event.device)
		
		
		elif Input.is_action_just_pressed("ui_cancel"):
			player_exit(event.device)


# player enters the game
func player_start(id):
	# Adds the player in the screen
	if not id in active_devices and active_players < 4:
		for pl in range(4):
			# searches for the first empty slot in the CSS
			# and adds the player there
			if selected_characters[pl] == null:
				active_players += 1
				selected_characters[pl] = available_characters.pop_front()
				active_devices[id] = pl + 1
				
				var character = selected_characters[pl]
				get_node(str("CSS/P", pl + 1,"/anim")).play("enter")
				print("player",pl)
				get_node(str("CSS/P", active_players,"/character")).set_animation(character)
				break
	
	# Removes the player if he's already there
	else:
		var player = active_devices[id]
		# Ready
		if get_node(str("CSS/P", player, "/label")).get_text() == "Ready?":
			get_node(str("CSS/P", player, "/label")).set_text("Ready for battle!!")
			ready_players.append(player)
		# Unready
		else:
			get_node(str("CSS/P", player, "/label")).set_text("Ready?")
			ready_players.remove(ready_players.find(player))
	
	
	# starts game
	if ready_players.size() == active_players and active_players >= 1:
		# sets the global variables to be used in the battle scene
		player_data.active_devices = active_devices
		player_data.selected_characters = selected_characters
		get_tree().change_scene("res://stages/battle.tscn")
		
	print(active_devices)

# player changes character
func player_change_char(id):
	if active_players > 0 and id in active_devices:
		var player = active_devices[id]
		
		# ready players cannot change character
		if not player in ready_players:
			# selects next available character
			if Input.is_action_just_pressed("ui_right"):
				# updates the list of available characters
				available_characters.append(selected_characters[player - 1])
				selected_characters[player - 1] = available_characters.pop_front()
			else:
				available_characters.push_front(selected_characters[player - 1])
				selected_characters[player - 1] = available_characters.pop_back()
			
			var character = selected_characters[player - 1]
			get_node(str("CSS/P", player, "/character")).set_animation(character)
		print(selected_characters)

# player "exits"
func player_exit(id):
	if id in active_devices and not active_devices[id] in ready_players:
		var player = active_devices[id]
			
		get_node(str("CSS/P", player,"/anim")).play("exit")
			
		available_characters.push_front(selected_characters[player - 1])
		selected_characters[player - 1] = null
		active_players -= 1
		active_devices.erase(id)
