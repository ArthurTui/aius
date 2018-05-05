extends "res://spells/base_spell.gd"

var SPEED = 3
const DAMAGE = 20
const KNOCKBACK = 50

var direction = Vector2(0, 0) # direction that the fireball flies to


#func _ready():
#	get_node( "SFX" ).play( "bubble" )


func fire(direction, caster):
	self.direction = direction
	self.caster = caster
	set_position(caster.position)
	set_process(true)


func _process(delta):
	position += direction * SPEED
	SPEED -= 0.75*delta
	if (SPEED <= 0):
		die()


# does damage if take damage function exists in body
func _on_projectile_body_entered(body):
	if body != caster:
		if body.has_method("take_damage"):
			var kb_direction = (body.position - position).normalized()
			body.take_damage(DAMAGE, kb_direction, KNOCKBACK)
		if body.has_method("slow"):
			# Applies slow effect 
			body.slow(2, 0.4)
		die()


func die():
	$projectile.queue_free()
	$sprite.play("death")
	set_process(false)


func _on_sprite_animation_finished():
	queue_free()
