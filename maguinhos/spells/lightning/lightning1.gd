extends "res://spells/base_spell.gd"

const ROTATION_SPEED = 3

var angle
var state = "going"


func fire(direction, caster):
	self.direction = direction
	self.caster = caster
	$projectile.caster = caster
	set_position(caster.position)
	set_process(true)


func _process(delta):
	if !caster or !weakref(caster).get_ref(): # caster was freed
		caster = null
		die()
		return
	
	if speed <= 0:
		state = "returning"
		angle = get_angle_to(caster.position)
		# negative cos and sin because speed is also negative
		direction = Vector2(-cos(angle), -sin(angle))
	$sprite.rotate(ROTATION_SPEED * delta)
	
	position += direction * speed
	speed -= 8*delta


# does damage if take damage function exists in body
func _on_projectile_body_entered(body):
	if body != caster:
		if body.has_method("take_damage"):
			body.take_damage(damage)
			$anim.play("blink")
		else:
			die()
	elif state == "returning":
		die()


func die():
	if $anim.is_playing():
		return
	$anim.play("death")
	if has_node("projectile"):
		$projectile.queue_free()
	$particles.emitting = false
	set_process(false)


func free_scn():
	queue_free()
