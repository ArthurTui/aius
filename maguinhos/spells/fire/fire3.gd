extends "res://spells/base_spell.gd"

const SPEED = 7
const DAMAGE = 35
const KNOCKBACK = 70

var direction = Vector2( 0, 0 ) # direction that the fireball flies to
var parent
var alive = true
var damaged_bodies = [] # prevents explosion from damaging more than once

func _ready():
	pass


func fire(direction, parent):
	self.direction = direction
	self.parent = parent
	self.has_activation = true
	set_position(parent.position)
	$trail.rotation = direction.angle()


func _process(delta):
	position += direction * SPEED


func _on_projectile_body_entered(body):
	if alive and body != parent:
		die()


# does damage if take damage function exists in body
func _on_explosion_body_entered( body ):
	if body != parent:
		if body.has_method("take_damage") and not body in damaged_bodies:
			body.take_damage(DAMAGE, self.direction, KNOCKBACK)
			damaged_bodies.append(body)


func _on_lifetime_timeout():
	die()


func _on_explosion_duration_timeout():
	$explosion.monitoring = false
	$free_timer.start()


func _on_free_timer_timeout():
	queue_free()


func activate():
	die()


func die():
	alive = false
	set_process(false)
	$projectile.queue_free()
	$lifetime.stop()
	$trail.emitting = false
	$explosion.monitoring = true
	$explosion/particles.emitting = true
	$explosion_duration.start()
	
	if !weakref(parent).get_ref(): # Parent was freed
		return
	parent.spell_ended() # Alerts player that spell is finished

