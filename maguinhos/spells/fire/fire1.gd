extends "res://spells/base_spell.gd"

export (int) var SPEED
export (int) var DAMAGE
export (int) var KNOCKBACK

var direction = Vector2(0, 0)
var owner_character

func _ready():
	pass


func fire(direction, owner_character):
	self.direction = direction
	self.owner_character = owner_character
	set_position(owner_character.position)
	set_rotation(direction.angle())


func _process(delta):
	position += direction * SPEED


func _on_projectile_body_entered(body):
	# does damage if take damage function exists in body
	if body != owner_character and body.is_dashing == false:
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
