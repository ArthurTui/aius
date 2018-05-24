extends "res://spells/base_spell.gd"

func cast(caster, direction):
	.cast(caster, direction)
	var angle_offset = -20
	for p in $Projectiles.get_children():
		var dir = direction.rotated(deg2rad(angle_offset))
		p.fire(caster, dir, speed, damage, knockback)
		angle_offset += 10


# Murders all children
func die():
	if dying:
		return
	.die()
	for p in $Projectiles.get_children():
		p.die()


func _on_Lifetime_timeout():
	die()
	$FreeTimer.start()


func _on_FreeTimer_timeout():
	queue_free()
