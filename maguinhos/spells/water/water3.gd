extends "res://spells/base_spell.gd"


func fire(direction, caster):
	self.direction = direction
	self.caster = caster
	$projectile.caster = caster
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
	if !has_node("projectile"):
		return
	for body in $projectile.get_overlapping_bodies():
		if body.has_method("take_damage") and body != caster:
			body.take_damage(DAMAGE)


func _on_projectile_body_entered(body):
	if (!body.is_in_group("Player")):
		# Dies when colliding with static objects
		die()
	elif body != caster:
		# Pushes back if target is an enemy
		body.push_direction = direction * SPEED
#		body.Slow(5, 0.3)


# Resets the push factor when exiting enemy
func _on_projectile_body_exited(body):
	if body.is_in_group("Player") and body != caster:
		body.push_direction = Vector2()
		body.slow(0.1,1)


func _on_lifetime_timeout():
	die()


func die():
	$anim.play("death")
	$projectile/shape.disabled = true


func free_scn():
	queue_free()
