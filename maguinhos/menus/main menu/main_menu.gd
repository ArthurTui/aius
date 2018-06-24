extends Control

var settings_scene = preload("res://menus/main menu/settings/Settings.tscn")
var credits_scene = preload("res://menus/main menu/Credits.tscn")

func _ready():
	$Buttons/Play.grab_focus()


func _on_Play_pressed():
	if not $Fade.is_playing():
		$Fade.play("fade_out")
		yield($Fade, "animation_finished")
		get_tree().change_scene("res://menus/character select/CSS.tscn")


func _on_Settings_pressed():
	var settings = settings_scene.instance()
	add_child(settings)
	yield(settings, "tree_exited")
	$Buttons/Settings.grab_focus()


func _on_Credits_pressed():
	var credits = credits_scene.instance()
	add_child(credits)
	yield(credits, "tree_exited")
	$Buttons/Credits.grab_focus()


func _on_Quit_pressed():
	get_tree().quit()
