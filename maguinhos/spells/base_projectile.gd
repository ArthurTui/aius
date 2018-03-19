extends Area2D

export (int, "Fire", "Water", "Lightning", "Nature") var element
export (int, 1, 3) var level

var parent

func _ready():
	parent = self.get_parent()
	pass

func _on_area_enter(area):
	var other = area.parent
	
	# Handle exceptions
	if area.get_name() == "DetectionArea":
		return
	if other == self:
		return
	if "parent" in other and other.parent == self.parent:
		return
	
	if "element" in area: # Makes sure it's something interactable with projectile
		if area.level > self.level:
			parent.die()
		elif area.element == (self.element + 1) % 4: # Oposing element
			if area.level < self.level: # Lower leveled spells have no effect
				return
			parent.die()
# Fire = 0, Water = 1, Lightning = 2, Nature = 3
