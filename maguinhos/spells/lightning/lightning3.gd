extends "res://spells/base_spell.gd"

const STUN_DURATION = 1.5

func cast(caster, direction):
	.cast(caster, direction)
	position.y -= 55
	rotation = direction.angle()
	$Sprite.play()
	emit_signal("shake_screen", shake)


func die():
	if dying:
		return
	.die()
	$Projectile/Shape.disabled = true


func _on_Projectile_body_entered(body):
	if body != caster:
		if body.has_method("take_damage"):
			body.take_damage(damage)
			body.stun(STUN_DURATION)


func _on_Sprite_animation_finished():
	queue_free()
