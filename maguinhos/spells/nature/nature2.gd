extends "res://spells/base_spell.gd"

const SEED_ROOT = .5
const THORN_ROOT = 1.5
const THORN_RADIUS = 35

var is_seed = true

func fire(direction, caster):
	self.direction = direction
	self.caster = caster
	rotation = direction.angle()
	set_position(caster.position)
	set_process(true)


func _process(delta):
	position += direction * speed


func _on_Area2D_body_enter(body):
	if body != caster:
		$GrowTimer.stop()
		if body.has_method("take_damage"):
			# If the thorns are grown, play death animation when enemy enters
			# them. Otherwise, the seed just disappears dealing damage
			if !is_seed:
				body.take_damage(2 * damage, null)
				body.root(THORN_ROOT)
				die()
			else:
#				var kb_direction = (body.position - position).normalized()
				body.take_damage(damage, null)
				body.root(SEED_ROOT)
				die()
		else:
			grow()


func _on_GrowTimer_timeout():
	grow()


# Projectile stops moving and expands
func grow():
	if !is_seed:
		return
	set_process(false)
	$LifeTimer.start()
	is_seed = false
	rotation = 0
	$AnimatedSprite.play("grow")
	$Projectile/CollisionShape2D.shape.radius = THORN_RADIUS


func _on_LifeTimer_timeout():
	die()


func die():
	if !has_node("Projectile"):
		return
	$Projectile.queue_free()
	if !is_seed:
		$AnimatedSprite.play("die")
		yield($AnimatedSprite, "animation_finished")
	queue_free()