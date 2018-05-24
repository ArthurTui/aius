extends "res://spells/base_spell.gd"


func fire(direction, caster):
	self.direction = direction
	self.caster = caster
	set_position(caster.position)
	set_process(true)


func _process(delta):
	position += direction * speed
	speed -= 0.75*delta
	if (speed <= 0):
		die()


# does damage if take damage function exists in body
func _on_projectile_body_entered(body):
	if body != caster:
		if body.has_method("take_damage"):
			var kb_direction = (body.position - position).normalized()
			body.take_damage(damage, kb_direction, knockback)
		if body.has_method("slow"):
			# Applies slow effect
			body.slow(2, 0.4)
		die()


func die():
	if has_node("projectile"):
		$projectile.queue_free()
	$sprite.play("death")
	set_process(false)


func _on_sprite_animation_finished():
	queue_free()
