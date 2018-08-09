extends Area2D

export (int, "Fire", "Water", "Lightning", "Nature") var element
export (int, 1, 3) var level

var caster

func _on_Projectile_area_entered(area):
	var other = area.get_parent()
	
	# Handle exceptions
	if other == self:
		return
	if "caster" in other and other.caster == self.caster:
		return
	
	# Projectile - Player collision:
#	if area.collision_layer == 2:
#		if other != caster:
#			get_parent().on_hit(other)
#		return
	
	# Projectile - Projectile collision:
	if "element" in area:
		# Makes sure it's something interactable with projectile
		if area.level > self.level:
			get_parent().die()
		elif area.element == (self.element + 1) % 4: # Oposing element
			if area.level == self.level: # Lower leveled spells have no effect
				get_parent().die()


func _on_Projectile_body_entered(body):
	if body.collision_layer == 1: # Character
		if body == caster:
			return
		get_parent().on_hit(body)
	get_parent().die()
