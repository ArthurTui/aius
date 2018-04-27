extends Node2D

const SPEED = 8
const ROTATION = 10
const DAMAGE = 5
const KNOCKBACK = 15

signal died(name)

var angle
var caster
var direction

func _ready():
	caster = get_parent().get_parent().caster
	set_process(false)


func shoot(direction):
	$sprite.set_modulate(Color(1, 1, 1, 1))
	$lifetime.start()
	self.direction = direction
	set_process(true)


func _process(delta):
	position += direction * SPEED
	rotation_degrees += ROTATION


func _on_projectile_body_entered(body):
	# does damage if take damage function exists in body
	if body != caster:
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE, self.direction, KNOCKBACK)
		die()


func monitor():
	if has_node("projectile"):
		$projectile.monitoring = true
		$projectile.monitorable = true


func remove_area():
	if has_node("projectile"):
		$projectile.queue_free()


func die():
	remove_area()
	set_process(false)
	emit_signal("died", get_name())
	$anim.play("death")
	yield($anim, "animation_finished")
	queue_free()


func selected():
	$sprite.set_modulate(Color(1, 5, 1, 1))


func _on_lifetime_timeout():
	die()
