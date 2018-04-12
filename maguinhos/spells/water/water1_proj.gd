extends "res://spells/base_projectile.gd"

const SPEED = 8
const DAMAGE = 4
const KNOCKBACK = 8

var direction = Vector2(0, 0)
var caster

func fire(direction, caster):
	self.direction = direction
	self.caster = caster
	
	set_process(true)


func _process(delta):
	position += direction * SPEED


# does damage if take damage function exists
func _on_projectile_body_entered(body):
	if body != caster:
		print(caster)
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE, self.direction, KNOCKBACK)
		die()


func die():
	if $sprite.animation == "death":
		return
	call_deferred("set_monitoring", false)
	call_deferred("set_monitorable", false)
	set_process(false)
	$sprite.play("death")
