extends "res://spells/base_spell.gd"

const HOMING_FACTOR = 20 # The lower the factor is, the faster the homing

var target

func cast(caster, direction):
	.cast(caster, direction)
	$DetectionArea.set_rotation(direction.angle())


func _process(delta):
	$Sprite.rotation = direction.angle()
	position += direction * speed
	if target:
		home()


# Given the conditions, homes in the direction of the target
func home():
	if target and !weakref(target).get_ref(): # target was freed
		target = null
	if !target:
		return
	
	var target_pos = target.position
	var dif = target_pos - self.position
	direction += dif.normalized() / HOMING_FACTOR
	
	direction.x = clamp(direction.x, -1.1, 1.1)
	direction.y = clamp(direction.y, -1.1, 1.1)


func on_hit(character):
	.on_hit(character)
	emit_signal("shake_screen", shake)


func die():
	if dying:
		return
	.die()
	$Projectile/Shape.disabled = true
	$Lifetime.stop()
	$Particles2D.emitting = false
#	set_process(false)
	death_animation()


func death_animation():
	# Animation duration
	var dur = .2
	
	$Tween.interpolate_property($Sprite, "scale", $Sprite.scale,
		Vector2(1.5, 1.5), dur, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.interpolate_property($Sprite, "modulate", $Sprite.modulate,
		Color(1, 1, 1, 0), dur, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.interpolate_property($Shadow, "scale", $Shadow.scale,
		1.5 * $Shadow.scale, dur, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.interpolate_property($Shadow, "modulate", $Shadow.modulate,
		Color(0, 0, 0, 0), dur, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()


func _on_DetectionArea_body_entered(body):
	if body.is_in_group("Player") and body != caster:
		target = body
		$DetectionArea.queue_free()


func _on_Lifetime_timeout():
	die()


func _on_Tween_tween_completed(object, key):
	# Allow time for particles to disappear
	$Lifetime.wait_time = .5
	$Lifetime.start()
	
	yield($Lifetime, "timeout")
	
	queue_free()
