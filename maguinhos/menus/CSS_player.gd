extends Container

# This function will be called at the end of a "ready" animation, so that the animation
# has time to end before the game starts, instead of checking as soon as a player readies
# and canceling the animation
func check_game_start():
	var ready_players = player_data.ready_players.size()
	var active_players = player_data.active_devices.size()
	
	if ready_players == active_players and ready_players >= 2:
		get_tree().change_scene("res://menus/stage_select.tscn")