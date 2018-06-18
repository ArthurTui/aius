extends "res://spells/base_spell.gd"

const ROOT_TIME = 2

func cast(caster, direction):
	.cast(caster, direction)
	rotation = direction.angle()
	$Animation.play("grow")
	yield($Animation, "animation_finished")
	queue_free()


func die():
	if dying:
		return
	.die()
	
	# Disabling shapes:
	for shape in $Projectile.get_children():
		shape.disabled = true
	
	# Darkening the sprite:
	$Sprite.modulate = $Sprite.modulate.darkened(.2)
	
	# Retracting or speeding up the vines:
	$Animation.playback_speed = 2
	if $Animation.current_animation_position <= .5:
		$Animation.playback_speed *= -1
	elif $Animation.current_animation_position <= .8:
		$Animation.seek(.8)


func _on_Projectile_body_entered(body):
	if body != caster and body.collision_layer == 1:
		body.take_damage(damage)
		body.root(ROOT_TIME)
