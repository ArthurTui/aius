extends Container

const characters = ["skeleton", "broleton"]

var active_devices = {} # which device controls which player
var selected_characters = [0,0,0,0]

var active_players = 0
var ready_players = []

var player

func _ready():
	set_process_input(true)

func _input(event):
	# player enters the game
	if Input.is_action_just_pressed("pause"):
		if not event.device in active_devices and active_players < 4:
			active_players += 1
			active_devices[event.device] = active_players
			get_node(str("P", active_players)).set_visible(true)
		
		else:
			player = active_devices[event.device]
			# Ready
			if get_node(str("P", player, "/label")).get_text() == "Ready?":
				get_node(str("P", player, "/label")).set_text("LESGO!!")
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
	
	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left"):
		if active_players > 0:
			player = active_devices[event.device]
			# selects next character
			if Input.is_action_just_pressed("ui_right"):
				selected_characters[player - 1] += 1
			else:
				selected_characters[player - 1] -= 1
			selected_characters[player - 1] %= characters.size()
			
			var character = characters[selected_characters[player - 1]]
			print(character)
			get_node(str("P", player, "/character")).set_animation(character)
			








