extends "res://spells/base_spell.gd"

const SEED_ROOT = .5
const THORN_OFFSET_Y = 15
const THORN_ROOT = 1.5
const THORN_RADIUS = 60

var is_seed = true

func cast(caster, direction):
	.cast(caster, direction)
	rotation = direction.angle()


func _process(delta):
	position += direction * speed


# Projectile stops moving and expands
func grow():
	if !is_seed:
		return
	set_process(false)
	$LifeTimer.start()
	is_seed = false
	rotation = 0
	$Sprite.play("grow")
	$Projectile/Shape.shape.radius = THORN_RADIUS
	$Projectile/Shape.position = Vector2(0, THORN_OFFSET_Y)


func die():
	if dying:
		return
	.die()
	$Projectile/Shape.disabled = true
	$GrowTimer.stop()
	if !is_seed:
		$Sprite.play("die")
		yield($Sprite, "animation_finished")
	else:
		$Tween.interpolate_property($Sprite, "scale", $Sprite.scale,
			Vector2(1.2, 1.2), .1, Tween.TRANS_SINE, Tween.EASE_IN)
		$Tween.interpolate_property($Sprite, "modulate", Color(1, 1, 1, 1),
			Color(1, 1, 1, 0), .1, Tween.TRANS_SINE, Tween.EASE_IN)
		$Tween.start()
		yield($Tween, "tween_completed")
	queue_free()


func _on_Projectile_body_entered(body):
	if body != caster:
		$GrowTimer.stop()
		if body.has_method("take_damage"):
			# If the thorns are grown, play death animation when enemy enters
			# them. Otherwise, the seed just disappears dealing damage
			if !is_seed:
				body.take_damage(2 * damage)
				body.root(THORN_ROOT)
			else:
				body.take_damage(damage)
				body.root(SEED_ROOT)
			die()
		else:
			grow()


func _on_LifeTimer_timeout():
	die()


func _on_GrowTimer_timeout():
	grow()
