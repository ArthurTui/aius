extends "res://spells/base_spell.gd"

export (int) var SPEED
export (int) var DAMAGE
export (int) var KNOCKBACK

var direction = Vector2(0, 0)
var parent

func _ready():
	pass


func fire(direction, parent):
	self.direction = direction
	self.parent = parent
	set_position(parent.position)
	set_rotation(direction.angle())


func _process(delta):
	position += direction * SPEED
#	move_and_collide( direction * SPEED )


func _on_projectile_body_entered(body):
	# does damage if take damage function exists in body
	if body != parent:
		$projectile.queue_free()
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE, self.direction, KNOCKBACK)
		die()


func _on_lifetime_timeout():
	die()


func die():
#	get_node( "SFX" ).play( "fireball" )
	$projectile.queue_free()
	$lifetime.queue_free()
	$anim.play("death")
	set_process(false)


func free_scn():
	queue_free()
