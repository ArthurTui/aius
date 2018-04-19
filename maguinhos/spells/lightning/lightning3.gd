extends "res://spells/base_spell.gd"

const DAMAGE = 20

func fire(direction, caster):
	self.caster = caster
	set_rotation(direction.angle())
	set_position(caster.position)
	$sprite.play()


func _on_projectile_body_entered(body):
	if body != caster:
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE, null)
			body.stun(1.5)


func _on_sprite_animation_finished():
	queue_free()
