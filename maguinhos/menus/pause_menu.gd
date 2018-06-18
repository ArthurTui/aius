extends Panel

var can_process = false
var hovered = 0

func _ready():
	self.visible = false
	get_tree().paused = false


func _input(event):
#	print("resume",$resume.rect_position)
	if Input.is_action_just_pressed("pause") and can_process:
		on_resume_pressed()
	if Input.is_action_just_pressed("ui_up"):
		$rect.set_position($resume.rect_position)
		hovered = 0
	elif Input.is_action_just_pressed("ui_down"):
		$rect.set_position($quit.rect_position)
		hovered = 1
		
	elif Input.is_action_just_pressed("ui_accept") and self.visible:
		match hovered:
			0:
				on_resume_pressed()
			1:
				on_quit_pressed()
	


func on_resume_pressed():
	get_tree().paused = not get_tree().is_paused()
	self.visible = not self.is_visible()
	

func on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://menus/CSS.tscn")

func _on_work_timer_timeout():
	can_process = true
