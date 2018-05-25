extends "res://spells/base_spell.gd"

func fire(caster, direction, speed, damage, knockback):
	self.caster = caster
	$Projectile.caster = caster
	self.direction = direction
	$Sprite.rotation = direction.angle()
	self.speed = speed
	self.damage = damage
	self.knockback = knockback


func _process(delta):
	position += direction * speed


func die():
	if $Tween.is_active():
		return
	$Projectile/Shape.disabled = true
	set_process(false)
	$Tween.interpolate_property($Sprite, "scale", Vector2(.15, .15),
		Vector2(.5, .5), .4, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.interpolate_property($Sprite, "modulate", Color(1, 1, 1, 1),
		Color(1, 1, 1, 0), .4, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()
	yield($Tween, "tween_completed")
	queue_free()


func _on_Projectile_body_entered(body):
	if body != caster:
		if body.has_method("take_damage"):
			var kb_direction = (body.position - global_position).normalized()
			body.take_damage(damage, kb_direction, knockback)
		die()
