extends Control

var hovering = 0 # which button is being hovered


func _ready():
	set_process(true)


func check_null():
	if hovering == 0:
		hovering = 1
		change_button(0, 1)
		return true
	return false


func _input(event):
	var prev = 0
	
	if Input.is_action_just_pressed("ui_up"):
		if check_null():
			return
		prev = hovering
		hovering -= 1
		if hovering <= 0:
			hovering = 4
		change_button(prev, hovering)
			
	elif Input.is_action_just_pressed("ui_down"):
		if check_null():
			return
		prev = hovering
		hovering += 1
		if hovering >= 5:
			hovering = 1
		change_button(prev, hovering)
	
	# settings and credits to be added here
	elif Input.is_action_just_pressed("ui_accept"):
		if check_null():
			return
		match hovering:
			1:
				_on_Play_pressed()
			4:
				_on_Quit_pressed()

# unhovers the prev button and hovers the new
func change_button(prev, new):
	match prev:
		1:
			_on_play_mouse_exited()
		2:
			_on_settings_mouse_exited()
		3:
			_on_credits_mouse_exited()
		4:
			_on_quit_mouse_exited()
	match new:
		1:
			_on_play_mouse_entered()
		2:
			_on_settings_mouse_entered()
		3:
			_on_credits_mouse_entered()
		4:
			_on_quit_mouse_entered()

func _on_Play_pressed():
	if not $fade.is_playing():
		$fade.play("fade_out")
	set_process(false)


func play_scene():
	get_tree().change_scene("res://menus/CSS.tscn")


func _on_Quit_pressed():
	get_tree().quit()

# button functions
######################################################

func _on_play_mouse_entered():
	hovering = 1
	$Buttons/Play/AnimationPlayer.play("play_hover")

func _on_settings_mouse_entered():
	hovering = 2
	$Buttons/Settings/AnimationPlayer.play("settings_hover")

func _on_credits_mouse_entered():
	hovering = 3
	$Buttons/Credits/AnimationPlayer.play("credits_hover")

func _on_quit_mouse_entered():
	hovering = 4
	$Buttons/Quit/AnimationPlayer.play("quit_hover")

######################################################
func _on_play_mouse_exited():
	hovering = 0
	$Buttons/Play/AnimationPlayer.play("play_unhover")


func _on_settings_mouse_exited():
	hovering = 0
	$Buttons/Settings/AnimationPlayer.play("settings_unhover")


func _on_credits_mouse_exited():
	hovering = 0
	$Buttons/Credits/AnimationPlayer.play("credits_unhover")


func _on_quit_mouse_exited():
	hovering = 0
	$Buttons/Quit/AnimationPlayer.play("quit_unhover")
