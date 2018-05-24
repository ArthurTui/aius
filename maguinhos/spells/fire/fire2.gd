extends "res://spells/base_spell.gd"

const HOMING_FACTOR = 20 # The lower the factor is, the faster the homing

var target

func cast(caster, direction):
	.cast(caster, direction)
	set_rotation(direction.angle())


func _process(delta):
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


func die():
	if dying:
		return
	.die()
	$Projectile/Shape.disabled = true
	$Lifetime.stop()
	set_process(false)
	death_animation()


func death_animation():
	# Animation duration
	var dur = .4
	
	$Tween.interpolate_property($Sprite, "scale", $Sprite.scale,
		Vector2(1.5, 1.5), dur, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.interpolate_property($Sprite, "modulate", $Sprite.modulate,
		Color(1, 1, 1, 0), dur, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()


func _on_DetectionArea_body_entered(body):
	if body != caster:
		target = body
		$DetectionArea.queue_free()


func _on_Lifetime_timeout():
	die()


func _on_Tween_tween_completed(object, key):
	queue_free()
