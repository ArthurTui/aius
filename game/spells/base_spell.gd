extends Node2D

const POSITION_OFFSET = 30

export (bool) var has_activation = false # for spells that require activation
export (int) var speed
export (int) var damage
export (int) var knockback
export (float) var shake

signal shake_screen(s)

var caster
var direction = Vector2()
var dying = false

func cast(caster, direction):
	self.caster = caster
	self.direction = direction
	position = caster.position + POSITION_OFFSET * direction
	connect("shake_screen", caster.get_parent().get_parent(), "shake_screen")
	if has_node("Projectile"):
		$Projectile.caster = caster


func on_hit(character):
	var kb_direction = (character.position - position).normalized()
	character.take_damage(damage, kb_direction, knockback)
	die()


func die():
	dying = true
