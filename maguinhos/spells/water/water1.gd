extends "res://spells/base_spell.gd"

func fire(direction, caster):
	set_position(caster.position + 30 * direction)
	$proj1.fire(direction, caster)
	$proj2.fire(direction.rotated(deg2rad(10)), caster)
	$proj3.fire(direction.rotated(deg2rad(-10)), caster)
	$proj4.fire(direction.rotated(deg2rad(20)), caster)
	$proj5.fire(direction.rotated(deg2rad(-20)), caster)


# murders all children
func die():
	for child in get_children():
		if child.has_method("die"):
			child.die()
	set_process(false)


func _on_lifetime_timeout():
	die()
	$free_timer.start()


func _on_free_timer_timeout():
	queue_free()
