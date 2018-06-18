extends "res://spells/base_spell.gd"

const SEED_ROOT = .5
const THORN_ROOT = 1.5

var is_seed = true

func cast(caster, direction):
	.cast(caster, direction)
	$Sprite.rotation = direction.angle()
	$Tween.interpolate_property($Sprite, "position", $Sprite.position,
		Vector2(), $GrowTimer.wait_time, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()


func _process(delta):
	position += direction * speed


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
		$Tween.stop_all()
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
		if body.collision_layer == 1: # Character
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
	# Projectile stops moving and expands
	if !is_seed:
		return
	set_process(false)
	$LifeTimer.start()
	is_seed = false
	$Tween.stop($Sprite, "position")
	$Sprite.position = Vector2(0, -35)
	$Sprite.rotation = 0
	$Sprite.play("grow")
	$Shadow.scale = Vector2(1.4, .7)
	$Projectile/Shape.shape.radius = 25
	$Projectile/Shape.shape.height = 80
