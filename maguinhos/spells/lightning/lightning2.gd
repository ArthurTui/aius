extends "res://spells/base_spell.gd"

const SPEED = 4
const DAMAGE = 20
const STUN_TIME = 1

var direction = Vector2(0, 0) # direction that the cloud flies to


func fire(direction, caster):
	self.direction = direction
	self.caster = caster
	$projectile.caster = caster
	set_position(caster.position)
	$sprite.hide()
	$anim.play("fire")


func _process(delta):
	position += direction * SPEED


# does damage if take damage function exists in body
func _on_projectile_body_entered(body):
	if body != caster:
		if not "health" in body: # target is not another player
			die()
			return
		# target is another player
		for b in $projectile.get_overlapping_bodies():
			if b != caster and body.has_method("take_damage"):
				b.take_damage(DAMAGE)
				b.stun(STUN_TIME)
		$sprite.show()
		$sprite.play("lightning")
		set_process(false)


func _on_lifetime_timeout():
	die()


func _on_sprite_animation_finished():
	die()


func die():
	if $anim.is_playing():
		return
	$projectile.queue_free()
	$anim.play("death")


func free_scn():
	queue_free()
