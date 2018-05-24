extends "res://spells/base_spell.gd"

const SLOW_DURATION = 1
const SLOW_MULTIPLIER = .1

func cast(caster, direction):
	.cast(caster, direction)
	if direction.x != 0:
		if direction.x < 0:
			$Sprite.flip_h = true
		$Sprite.play("side")
	elif direction.y >= 0.9:
		$Sprite.play("down")
	elif direction.y <= -0.9:
		$Sprite.play("up")


func _process(delta):
	position += direction * speed
	for body in $Projectile.get_overlapping_bodies():
		if body.has_method("take_damage") and body != caster:
			body.take_damage(damage)


func _on_Projectile_body_entered(body):
	if (!body.is_in_group("Player")):
		# Dies when colliding with static objects
		die()
	elif body != caster:
		# Pushes back if target is an enemy
		body.push_direction = direction * speed


func _on_Projectile_body_exited(body):
	# Resets the push factor when exiting enemy
	if body.is_in_group("Player") and body != caster:
		body.push_direction = Vector2()
		body.slow(SLOW_DURATION, SLOW_MULTIPLIER)


func die():
	if dying:
		return
	.die()
	$Projectile/Shape.disabled = true
	$Tween.interpolate_property($Sprite, "modulate", Color(1, 1, 1, 1),
		Color(1, 1, 1, 0), .2, Tween.TRANS_SINE, Tween.EASE_IN)
	$Tween.start()
	yield($Tween, "tween_completed")
	queue_free()


func _on_Lifetime_timeout():
	die()
