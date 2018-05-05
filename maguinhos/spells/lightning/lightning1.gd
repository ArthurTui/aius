extends "res://spells/base_spell.gd"

var SPEED = 10
const DAMAGE = 5
var ROT_SPEED = 3

var direction = Vector2(0, 0) # direction that the fireball flies to
var angle
var state = "going"


func fire(direction, caster):
	self.direction = direction
	self.caster = caster
	$projectile.caster = caster
	set_position(caster.position)
	set_process(true)


func _process(delta):
	if !weakref(caster).get_ref(): # caster was freed
		caster = null
		die()
		return
	
	if SPEED <= 0:
		state = "returning"
		angle = get_angle_to(caster.position)
		# negative cos and sin because speed is also negative
		direction = Vector2(-cos(angle), -sin(angle))
	$sprite.rotate(ROT_SPEED * delta)
	
	position += direction * SPEED
	SPEED -= 8*delta


# does damage if take damage function exists in body
func _on_projectile_body_entered(body):
	if body != caster:
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE)
			$anim.play("blink")
	elif state == "returning":
		die()


func die():
	$anim.play("death")
	$projectile.queue_free()
	$particles.emitting = false
	set_process(false)


func free_scn():
	queue_free()
