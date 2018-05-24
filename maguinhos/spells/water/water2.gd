extends "res://spells/base_spell.gd"

const DAMPING = .01
const MIN_SPEED = .2
const SLOW_DURATION = 2
const SLOW_MULTIPLIER = .4

var real_position
var time = 0

func cast(caster, direction):
	.cast(caster, direction)
	real_position = position

func _process(delta):
	real_position += direction * speed
	time += delta
	position = real_position + Vector2(0, 8 * cos(3 * time))
	speed = lerp(speed, 0, DAMPING)
	if (speed <= MIN_SPEED):
		die()


func on_hit(body):
	.on_hit(body)
	if body.has_method("slow"):
		body.slow(SLOW_DURATION, SLOW_MULTIPLIER)


func die():
	if dying:
		return
	.die()
	$Projectile/Shape.disabled = true
	$Sprite.play("death")
	set_process(false)


func _on_Sprite_animation_finished():
	queue_free()
