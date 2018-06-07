extends Node2D

const POSITION_OFFSET = 30

export (bool) var has_activation = false # for spells that require activation
export (int) var speed
export (int) var damage
export (int) var knockback

var caster
var direction = Vector2()
var dying = false


func cast(caster, direction):
	self.caster = caster
	self.direction = direction
	position = caster.position + caster.CAST_ORIGIN + POSITION_OFFSET*direction
	if has_node("Projectile"):
		$Projectile.caster = caster


func on_hit(body):
	var kb_direction = (body.position - position).normalized()
	body.take_damage(damage, kb_direction, knockback)


func die():
	dying = true


func _on_Projectile_body_entered(body):
	# Hits body if "take_damage" function exists in it then dies, else just dies
	if body != caster:
		if body.has_method("take_damage"):
			on_hit(body)
		die()
