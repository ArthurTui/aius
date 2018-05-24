extends "res://spells/base_spell.gd"

const SPEED = 7
const DAMAGE = 35
const KNOCKBACK = 70

var direction = Vector2() # direction that the fireball flies to
var alive = true
var damaged_bodies = [] # prevents explosion from damaging more than once

func _ready():
	pass


func fire(direction, caster):
	self.direction = direction
	self.caster = caster
	$projectile.caster = caster
	$explosion.caster = caster
	self.has_activation = true
	set_position(caster.position)
	$trail.rotation = direction.angle()


func _process(delta):
	position += direction * SPEED


func _on_projectile_body_entered(body):
	if alive and body != caster:
		# checks if it's a player before checking if it's dashing,
		# so that only the fireball explodes, and not the code
		if body.is_in_group("Player") and body.is_dashing == false:
			die()
		elif not body.is_in_group("Player"):
			die()


# does damage if take damage function exists in body
func _on_explosion_body_entered(body):
	if body != caster:
		if body.has_method("take_damage") and not body in damaged_bodies:
			var kb_direction = (body.position - position).normalized()
			body.take_damage(DAMAGE, kb_direction, KNOCKBACK)
			damaged_bodies.append(body)


func _on_lifetime_timeout():
	die()


func _on_explosion_duration_timeout():
	if has_node("explosion"):
		$explosion.monitoring = false
	$free_timer.start()


func _on_free_timer_timeout():
	queue_free()


func activate():
	die()


func die():
	alive = false
	set_process(false)
	if has_node("projectile"):
		$projectile/sprite.visible = false
		$projectile.queue_free()
	else:
		print("why kei")
	$trail.emitting = false
	if has_node("explosion"):
		$explosion.monitoring = true
		if has_node("explosion/particles"):
			$explosion/particles.emitting = true
		$explosion_duration.start()
	
	if !caster or !weakref(caster).get_ref(): # Caster was freed
		return
	caster.spell_ended() # Alerts player that spell is finished

