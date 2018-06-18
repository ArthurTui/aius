extends "res://spells/base_spell.gd"

const ACCELERATION = 8
const ROTATION_SPEED = 3

var returning = false

func _process(delta):
	if !caster or !weakref(caster).get_ref(): # caster was freed
		caster = null
		die()
		return
	
	if speed <= 0:
		var angle = get_angle_to(caster.position + caster.cast_pos)
		# negative cos and sin because speed is also negative
		direction = Vector2(-cos(angle), -sin(angle))
	
	$Sprite.rotate(ROTATION_SPEED * delta)
	
	position += direction * speed
	speed -= ACCELERATION * delta


func die():
	if dying:
		return
	.die()
	$Projectile/Shape.disabled = false
	$Particles.emitting = false
	set_process(false)
	death_animation()


func death_animation():
	var duration = .3
	
	$Tween.interpolate_property($Sprite, "scale", Vector2(1, 1),
		Vector2(.2, .2), duration, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.interpolate_property($Sprite, "modulate", Color(1, 1, 1, 1),
		Color(1, 1, 1, 0), duration, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.interpolate_property($Shadow, "scale", $Shadow.scale,
		.2 * $Shadow.scale, duration, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.interpolate_property($Shadow, "modulate", $Shadow.modulate,
		Color(0, 0, 0, 0), duration, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()
	
	yield($Tween, "tween_completed")
	queue_free()


func on_hit(character):
	character.take_damage(damage)
	$Animation.play("blink")


func _on_Projectile_body_entered(body):
	if body.collision_layer == 1: # Character
		if body != caster:
			on_hit(body)
			return
		elif !returning:
			return
	die()


func _on_Return_timeout():
	returning = true
