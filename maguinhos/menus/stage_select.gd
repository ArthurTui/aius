extends Control

const stage_names = ["forest", "river", "city", "cave"]


func _ready():
	pass


func _process(delta):
	# left controller axis
	var h = Input.get_joy_axis(0, 0)/2 # horizontal
	var v = Input.get_joy_axis(0, 1)/2 # vertical
	var direction = Vector2(0, 0)
	
	
	if Input.is_action_pressed("ui_up"):
	    direction -= Vector2( 0, 1 )
	if Input.is_action_pressed("ui_right"):
	    direction += Vector2( 1, 0 )
	if Input.is_action_pressed("ui_down"):
	    direction += Vector2( 0, 1 )
	if Input.is_action_pressed("ui_left"):
	    direction -= Vector2( 1, 0 )
	
	
	direction.x += h
	direction.y += v
	
	if direction.x <= 0.05 and direction.x >= -0.05:
		direction.x = 0
	if direction.y <= 0.05 and direction.y >= -0.05:
		direction.y = 0
		
	$cursor.position += direction * 10
	var cursor_pos = $cursor.get_position()
	
	for node in $stages.get_children():
		if node.name in stage_names and node.get_child(0).overlaps_body($cursor):
			if Input.is_action_just_pressed("ui_accept"):
				if node.name == "forest":
					get_tree().change_scene("res://stages/forest.tscn")
				else:
					print(node.name)