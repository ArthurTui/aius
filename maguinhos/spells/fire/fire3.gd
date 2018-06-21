extends "res://spells/base_spell.gd"

var damaged_bodies = [] # prevents explosion from damaging more than once

func cast(caster, direction):
	.cast(caster, direction)
	$Explosion.caster = caster
	$Trail.rotation = direction.angle()


func _process(delta):
	position += direction * speed


func activate():
	die()


func on_hit(body):
	if body in damaged_bodies:
		return
	damaged_bodies.append(body)
	.on_hit(body)


func die():
	if dying:
		return
	.die()
	emit_signal("shake_screen", shake)
	set_process(false)
	$Sprite.visible = false
	$Shadow.visible = false
	$Projectile/Shape.disabled = true
	$Trail.emitting = false
	$Explosion/Shape.disabled = false
	$ExplosionParticles.emitting = true
	$ExplosionDuration.start()
	$Lifetime.stop()
	
	if !caster or !weakref(caster).get_ref(): # Caster was freed
		return
	caster.spell_ended() # Alerts player that spell is finished


func _on_Lifetime_timeout():
	die()


func _on_ExplosionDuration_timeout():
	$Explosion/Shape.disabled = true
	$FreeTimer.start()


func _on_FreeTimer_timeout():
	queue_free()
