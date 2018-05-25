extends "res://spells/base_spell.gd"

const STUN_TIME = 1
const CLOUD_Y = -400

func cast(caster, direction):
	.cast(caster, direction)
	$Sprite.hide()
	entry_animation()


func entry_animation():
	var duration = .2
	$Tween.interpolate_property($Cloud, "position", $Cloud.position,
		Vector2(0, CLOUD_Y), duration, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.interpolate_property($Cloud, "modulate", Color(1, 1, 1, 0),
		Color(1, 1, 1, 1), duration, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.interpolate_property($Shadow, "modulate", Color(1, 1, 1, 0),
		Color(1, 1, 1, .5), duration, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()


func _process(delta):
	position += direction * speed


func on_hit(body):
	for b in $Projectile.get_overlapping_bodies():
		if b != caster and body.has_method("take_damage"):
			b.take_damage(damage)
			b.stun(STUN_TIME)
	
	$Sprite.show()
	$Sprite.play("lightning")
	$Particles.emitting = true
	set_process(false)


func die():
	if dying:
		return
	.die()
	$Projectile/Shape.disabled = false
	
	var duration = .2
	$Tween.remove_all()
	$Tween.interpolate_property($Cloud, "modulate", $Cloud.modulate,
		Color(1, 1, 1, 0), duration, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.interpolate_property($Shadow, "modulate", $Shadow.modulate,
		Color(1, 1, 1, 0), duration, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()
	
	yield($Tween, "tween_completed")
	queue_free()


func _on_Projectile_body_entered(body):
	# Hits body if "take_damage" function exists in it, else just dies
	if body != caster:
		if body.has_method("take_damage"):
			on_hit(body)
		else:
			die()


func _on_Sprite_animation_finished():
	die()


func _on_Lifetime_timeout():
	die()
