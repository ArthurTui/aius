extends Control

const characters = ["skeleton", "broleton", "sealeton", "bloodyskel"]

var active_devices = {} # which device controls which player
var selected_characters = [0,0,0,0]
var available_characters = [0,1,2,3]

var active_players = 0 # number of active players
var ready_players = [] # which players are active

var player

func _ready():
	set_process_input(true)

func _input(event):
	var id = event.device
	# player enters the game
	if Input.is_action_just_pressed("pause"):
		if not id in active_devices and active_players < 4:
			active_players += 1
			active_devices[id] = active_players
			player = active_devices[id]
			selected_characters[player - 1] = available_characters.pop_front()
			get_node(str("P", active_players,"/anim")).play("enter")
			
			var character = characters[selected_characters[player - 1]]
			get_node(str("P", active_players,"/character")).set_animation(character)
		
		else:
			player = active_devices[id]
			# Ready
			if get_node(str("P", player, "/label")).get_text() == "Ready?":
				get_node(str("P", player, "/label")).set_text("Ready for battle!!")
				ready_players.append(player)
			# Unready
			else:
				get_node(str("P", player, "/label")).set_text("Ready?")
				ready_players.remove(ready_players.find(player))
			print(ready_players)
		
		# starts game
		if ready_players.size() == active_players and active_players >= 2:
			print("lesgo bois")
			pass
		print(active_devices)
	
	# player changes character
	elif Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left"):
		if active_players > 0:
			player = active_devices[id]
			
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
				
				var character = characters[selected_characters[player - 1]]
				get_node(str("P", player, "/character")).set_animation(character)
	
	# player "exits"
	elif Input.is_action_just_pressed("ui_cancel"):
		if id in active_devices and not active_devices[id] in ready_players:
			get_node(str("P", active_players,"/anim")).play("exit")
			
			player = active_devices[id]
			available_characters.push_front(selected_characters[player - 1])
			selected_characters[player - 1] = -1
			active_players -= 1
			active_devices.erase(id)
			
# MOST ARRAYS STILL UNTESTED/PRINTED







