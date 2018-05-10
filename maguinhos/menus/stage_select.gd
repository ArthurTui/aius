extends Control


func _ready():
	pass


func _process(delta):
	var direction = Vector2(0, 0)
	
	if Input.is_action_pressed(str("ui_left")):
	    direction -= Vector2( 1, 0 )
	if Input.is_action_pressed(str("ui_right")):
	    direction += Vector2( 1, 0 )
	if Input.is_action_pressed(str("ui_down")):
	    direction += Vector2( 0, 1 )
	if Input.is_action_pressed(str("ui_up")):
	    direction -= Vector2( 0, 1 )
		
	var pos = $cursor.get_position() + (direction.normalized())
	print (pos)
	$cursor.set_position(pos)