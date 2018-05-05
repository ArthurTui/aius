extends Area2D

export (int, "Fire", "Water", "Lightning", "Nature") var element
export (int, 1, 3) var level

var caster

func _ready():
	pass

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
			get_parent().die()
# Fire = 0, Water = 1, Lightning = 2, Nature = 3
