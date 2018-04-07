extends "res://spells/base_spell.gd"


#func _ready():
#	get_node( "SFX" ).play( "splash" )


func fire( direction, parent ):

	set_rotation( direction.angle() - deg2rad(90) )
	set_position(parent.position + 30 * direction)
	print(direction)
	get_node("Projectile1").fire(direction, parent)
	get_node("Projectile2").fire(direction.rotated(deg2rad(10)), parent)
	get_node("Projectile3").fire(direction.rotated(deg2rad(-10)), parent)
	get_node("Projectile4").fire(direction.rotated(deg2rad(20)), parent)
	get_node("Projectile5").fire(direction.rotated(deg2rad(-20)), parent)
	

# murders all children
func die():
	for child in get_children():
		if child.has_method("die"):
			child.die()
	set_process( false )


func _on_LifeTimer_timeout():
	die()


func _on_FreeTimer_timeout():
	queue_free()
