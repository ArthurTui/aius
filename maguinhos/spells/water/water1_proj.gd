extends "res://spells/base_projectile.gd"

const SPEED = 8
const DAMAGE = 4
const KNOCKBACK = 8

var direction = Vector2(0, 0)

func fire(direction, caster):
	self.direction = direction
	self.caster = caster
	
	set_process(true)


func _process(delta):
	position += direction * SPEED


# does damage if take damage function exists
func _on_projectile_body_entered(body):
	if body != caster:
		if body.has_method("take_damage"):
			var kb_direction = (body.position - position).normalized()
			body.take_damage(DAMAGE, kb_direction, KNOCKBACK)
		die()


func die():
	if $sprite.animation == "death":
		return
	$shape.disabled = true
	set_process(false)
	$sprite.play("death")


func _on_projectile_area_entered(area):
	var other = area.get_parent()
	
	# Handle exceptions
	if area.get_name() == "detection_area":
		return
	if other == self:
		return
	if "caster" in other and other.caster == self.caster:
		return
	
	if "element" in area: # Makes sure it's something interactable with projectile
		if area.level > self.level:
			get_parent().die()
		elif area.element == (self.element + 1) % 4: # Oposing element
			if area.level < self.level: # Lower leveled spells have no effect
				return
			die()
# Fire = 0, Water = 1, Lightning = 2, Nature = 3
