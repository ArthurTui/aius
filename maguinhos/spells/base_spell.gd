extends KinematicBody2D

# Charge and cooldown times (in seconds)
export (int) var charge
export (int) var cooldown
export (bool) var has_activation = false

func _ready():
	pass


func _on_Area2D_area_enter( area ):
	var other = area.get_parent()
	
	# Handle exceptions
	if area.get_name() == "DetectionArea":
		return
	if other == self:
		return
	if "parent" in other:
		if other.parent == self.parent:
			return

	if "element" in other: # Makes sure it's something interactable with projectile
		if other.level > self.level:
			die()
		elif other.element == (self.element + 1) % 4: # Oposing element
			if other.level < self.level: # Lower leveled spells have no effect
				return
			die()
# Lightning = 0, Nature = 1, Fire = 2, Water = 3