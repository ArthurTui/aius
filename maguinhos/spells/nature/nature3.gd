extends "res://spells/base_spell.gd"

const DAMAGE = 10
const ROOT_TIME = 2

func fire(direction, caster):
	self.caster = caster
	position = caster.position
	rotation = direction.angle()
	$anim.play("grow")
	yield($anim, "animation_finished")
	queue_free()


func _on_projectile_body_entered(body):
	if body != caster:
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE, null)
			body.root(ROOT_TIME)
