extends "res://spells/base_spell.gd"

export (int) var SPEED
export (int) var DAMAGE
export (int) var KNOCKBACK

var direction = Vector2(0, 0)

func _ready():
	pass


func fire(direction, caster):
	self.direction = direction
	self.caster = caster
	set_position(caster.position)
	set_rotation(direction.angle())


func _process(delta):
	position += direction * SPEED


func _on_projectile_body_entered(body):
	# does damage if take damage function exists in body
	if body != caster:
		if body.has_method("take_damage"):
			var kb_direction = (body.position - position).normalized()
			body.take_damage(DAMAGE, kb_direction, KNOCKBACK)
		die()


func _on_lifetime_timeout():
	die()


func die():
	$projectile/shape.disabled = true
	$lifetime.queue_free()
	$anim.play("death")
	set_process(false)


func free_scn():
	queue_free()
