extends Panel

var can_process = false

func _ready():
	self.visible = false
	get_tree().paused = false


func _process(delta):
	# for some reason, the "start" a player pressed on the CSS
	# was registered here and paused the game everytime the
	# battle scene was instanciated, so the "can_process" variable
	# and the work timer are a workaround
	if Input.is_action_just_pressed("pause") and can_process:
		_on_resume_pressed()


func _on_resume_pressed():
	get_tree().paused = not get_tree().is_paused()
	self.visible = not self.is_visible()
	

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://menus/CSS.tscn")

func _on_work_timer_timeout():
	can_process = true
