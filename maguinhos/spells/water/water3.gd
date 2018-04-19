extends "res://spells/base_spell.gd"

const SPEED = 5

var direction = Vector2(0, 0) # direction that the wave goes to


func fire(direction, caster):
	self.direction = direction
	self.caster = caster
	set_position(caster.position)
	if direction.x != 0:
		if direction.x < 0:
			$sprite.flip_h = true
			set_position(self.position + Vector2(-60, 30))
		else:
			set_position(self.position + Vector2(60, 30))
		$sprite.play("side")
	elif direction.y >= 0.9:
		$sprite.play("down")
	elif direction.y <= -0.9:
		$sprite.play("up")


func _process(delta):
	position += direction * SPEED 


func _on_projectile_body_entered(body):
	if (!body.is_in_group("Player")):
		# Dies when colliding with static objects
		die()
	elif body != caster:
		# Pushes back if target is an enemy
		body.take_damage(5, self.direction, 0)
		body.push_direction = direction * 5
#		body.Slow(5, 0.3)


# Resets the push factor when exiting enemy
func _on_projectile_body_exited(body):
	if body.is_in_group("Player") and body != caster:
		body.push_direction = Vector2(0, 0)
		body.slow(0.1,1)


func _on_lifetime_timeout():
	die()


func die():
	$projectile.queue_free()
	$anim.play("death")
#	set_process(false)


func free_scn():
	queue_free()
