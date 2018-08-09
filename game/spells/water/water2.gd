extends "res://spells/base_spell.gd"

const DAMPING = .01
const MIN_SPEED = .2
const SLOW_DURATION = 2
const SLOW_MULTIPLIER = .4

var time = 0

func cast(caster, direction):
	.cast(caster, direction)

func _process(delta):
	position += direction * speed
	time += delta
	$Sprite.position = Vector2(0, -75 + 8 * cos(3 * time))
	speed = lerp(speed, 0, DAMPING)
	if (speed <= MIN_SPEED):
		die()


func on_hit(body):
	.on_hit(body)
	emit_signal("shake_screen", shake)
	if body.has_method("slow"):
		body.slow(SLOW_DURATION, SLOW_MULTIPLIER)


func die():
	if dying:
		return
	.die()
	$Projectile/Shape.disabled = true
	$Sprite.play("death")
	$SFX_Die.play()
	set_process(false)


func _on_Sprite_animation_finished():
	queue_free()
