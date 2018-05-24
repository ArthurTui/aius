extends Node2D

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


func on_hit(body):
	var kb_direction = (body.position - position).normalized()
	body.take_damage(damage, kb_direction, knockback)


func die():
	if dying:
		return
	dying = true


func _on_Projectile_body_entered(body):
	# Hits body if "take_damage" function exists in it, else just dies
	if body != caster:
		if body.has_method("take_damage"):
			on_hit(body)
		die()
