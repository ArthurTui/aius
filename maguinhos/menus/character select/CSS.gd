extends Control

# would be preferrable not to change these numbers
const KB_CUSTOM_ID_1 = 100
const KB_CUSTOM_ID_2 = 200

onready var quit_bar = $CSS/Back/VBox/QuitBar

const characters = ["skeleton", "broleton", "char1", "char1_2"]
var active_devices = {} # which device controls which player
var hovered = [-1, -1, -1, -1] # which character each slot has hovered,
							   # represented by their index in the character array
var selected_characters = [null, null, null, null]
var ready_players = [] # which players are ready


func _ready():
	player_data.characters = characters
	set_process_input(true)
	set_physics_process(true)


func _physics_process(delta):
	# adds progress to a quit progress bar. When full, quits to the main menu
	if Input.is_action_pressed("ui_cancel"):
		quit_bar.show()
		quit_bar.value += 1
		if quit_bar.get_value() >= quit_bar.get_max():
			get_tree().change_scene("res://menus/main menu/main_menu.tscn")
	
	# if cancel is not being held, subtracts from the quit bar
	else:
		quit_bar.value -= 1
		if quit_bar.get_value() <= 0:
			quit_bar.hide()



func _input(event):
	var id
	# detects a keyboard event and changes id so that the first
	# controller and the keyboard don't overlap inputs
	if Input.is_action_just_pressed("d100_enter"):
		id = KB_CUSTOM_ID_1
	elif Input.is_action_just_pressed("d100_left") or Input.is_action_just_pressed("d100_right"):
		id = KB_CUSTOM_ID_1
	elif Input.is_action_just_pressed("d100_cancel"):
		id = KB_CUSTOM_ID_1
	elif Input.is_action_just_pressed("d200_enter"):
		id = KB_CUSTOM_ID_2
	elif Input.is_action_just_pressed("d200_left") or Input.is_action_just_pressed("d200_right"):
		id = KB_CUSTOM_ID_2
	elif Input.is_action_just_pressed("d200_cancel"):
		id = KB_CUSTOM_ID_2
	else:
		 id = event.device
	
	
	if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("ui_accept"):
	    player_start(id)
	
	
	elif Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left"):
	    player_change_char(id)
	
	
	elif Input.is_action_just_pressed("ui_cancel"):
	    player_exit(id)


# player enters the game
func player_start(id):
	# Adds the player in the screen
	if not id in active_devices and active_devices.size() < 4:
		for pl in range(4):
			# searches for the first empty slot in the CSS
			# and adds the player there
			if hovered[pl] == -1:
				hovered[pl] = 0
				active_devices[id] = pl + 1
				
				var character = characters[0]
				get_node(str("CSS/P", pl + 1,"/Items/bg/bg_anim")).play("enter")
				get_node(str("CSS/P", pl + 1,"/Items/character")).set_animation(character)
				get_node(str("CSS/P", pl + 1,"/Items/enter_timer")).start()
				break
	
	# Removes the player if he's already there, and the timer has ended
	else:
		var player = active_devices[id]
		
		var timer = get_node(str("CSS/P", player,"/Items/enter_timer"))
		var anim = get_node(str("CSS/P", player, "/Items/anim"))
		
		if timer.is_stopped() and not anim.is_playing():
		
			# Ready
			if not player in ready_players:
				var idx = hovered[player - 1]
				var character = characters[idx]
				
				# if no one has already selected that caracter, readies
				if not character in selected_characters:
					selected_characters[player - 1] = character
					ready_players.append(player)
					
					# updates the global variables
					player_data.ready_players = ready_players
					player_data.active_devices = active_devices
					player_data.selected_characters = selected_characters
					player_data.hovered = hovered
					anim.play("ready")
				
				# cannot select an already selected character
				else:
					anim.play("shake")
			
			# Unready
			else:
				ready_players.remove(ready_players.find(player))
				selected_characters[player - 1] = null
				
				# updates the global variables
				player_data.active_devices = active_devices
				player_data.selected_characters = selected_characters
				player_data.hovered = hovered
				
				anim.play("unready")


# player changes character
func player_change_char(id):
	if active_devices.size() > 0 and id in active_devices:
		var player = active_devices[id]
		var char_anim = get_node(str("CSS/P", player, "/Items/character/char_anim"))
		
		# ready players cannot change character
		if not player in ready_players and not char_anim.is_playing():
			# selects next available character and updates
			# the list of hovered characters
			if Input.is_action_just_pressed("ui_right"):
				hovered[player - 1] += 1
				hovered[player - 1] %= characters.size()
			else:
				hovered[player - 1] -= 1
				if hovered[player - 1] == -1:
					hovered[player - 1] = characters.size() - 1
			
			var idx = hovered[player - 1]
			var character = characters[idx]
			
			# update global variables, because the CSS_player code is going to use
			# them in the next animation
			player_data.hovered = hovered
			char_anim.play("change")


# player "exits"
func player_exit(id):
	if id in active_devices and not active_devices[id] in ready_players:
		var player = active_devices[id]
		
		hovered[player - 1] = -1
		active_devices.erase(id)
		player_data.ready_players = ready_players
		player_data.active_devices = active_devices
		get_node(str("CSS/P", player,"/Items/bg/bg_anim")).play("exit")