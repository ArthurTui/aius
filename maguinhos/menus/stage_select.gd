extends Control


const stage_names = ["forest", "river", "city", "cave", "random"]
var stages_hovered = [false, false, false, false]


func _ready():
	randomize()


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
		var name = node.name
		
		if name in stage_names:
			var idx = stage_names.find(name)
			
			if node.get_child(0).overlaps_body($cursor):
				
				# shows stage info
				if idx < 4 and not stages_hovered[idx]:
					stages_hovered[idx] = true
					$stages.get_node(str(name,"/info")).show()
				
				# changes random's color if hovered
				if idx == 4:
					$stages/random.set_frame_color("7ef55c") # green
				
				# stage was selected
				if Input.is_action_just_pressed("ui_accept"):
					if idx < 4: # name is not "random"
						# we'll use this once all stages are instanceable
						#get_tree().change_scene(str("res://stages/",name,".tscn"))
						
						if name == "forest":
							get_tree().change_scene("res://stages/forest.tscn")
						
					# random stage, also teleports the cursor to the stage
					# the random chose
					else:
						var stage = stage_names[randi() % 4]
						var pos = $stages.get_node(stage).get_position()
						pos += $stages.get_node(stage).get_pivot_offset()
						$cursor.position = pos
						
			# hides stage info
			elif idx < 4 and stages_hovered[idx]:
				stages_hovered[idx] = false
				$stages.get_node(str(name,"/info")).hide()
				
			# resets random's color
			if not $stages/random/Area2D.overlaps_body($cursor):
				$stages/random.set_frame_color("7ad6ef") # blue