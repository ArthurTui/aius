extends Panel


func _ready():
	self.visible = false


func _process(delta):
	if Input.is_action_just_pressed("pause"):
		_on_unpause_pressed()


func _on_unpause_pressed():
	get_tree().paused = not get_tree().is_paused()
	self.visible = not self.is_visible()

func _on_quit_pressed():
	get_tree().change_scene("res://menus/main_menu.tscn")
