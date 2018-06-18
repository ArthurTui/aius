extends "res://spells/base_spell.gd"

const ROTATION_SPEED = 5
const SHIELD_RADIUS = 80

var can_shoot = false
var leaves = []
var n_leaves = 4
var radius = 0
var rot = 0
var selected_leaf = null

func _ready():
	var angle = 0
	for leaf in leaves:
		leaf.get_node("Sprite").set_rotation(rad2deg(angle))
		angle -= PI/2
	$Tween.interpolate_property(self, "radius", 0, SHIELD_RADIUS, .2,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()


func cast(caster, direction):
	leaves = [$Leaf1, $Leaf2, $Leaf3, $Leaf4]
	selected_leaf = leaves[0].selected()
	self.caster = caster
	self.direction = direction
	position = caster.position
	for leaf in leaves:
		remove_child(leaf)
		caster.get_parent().add_child(leaf)
		leaf.caster = caster
		leaf.get_node("Projectile").caster = caster
		print(leaf.caster)


func activate():
	if n_leaves > 0 and can_shoot:
		var i = leaves.find(selected_leaf)
		leaves[i] = null
		n_leaves -= 1
		selected_leaf.shoot(caster, caster.current_direction.normalized())
		
		for leaf in leaves:
			if leaf:
				selected_leaf = leaf.selected()
				return
		die()


func _process(delta):
	if !caster or !weakref(caster).get_ref(): # caster was freed
		caster = null
		die()
		return
	position = caster.position
	
	rot += ROTATION_SPEED * delta
	var angle = rot
	for leaf in leaves:
		if leaf:
			leaf.get_node("Sprite").set_rotation(angle)
			leaf.position = position + Vector2(radius, 0).rotated(angle)
		angle -= PI/2


func die():
	if dying:
		return
	.die()
	
	if caster and weakref(caster).get_ref():
		caster.spell_ended()
	
	$Tween.interpolate_property(self, "radius", radius, 0, .2, Tween.TRANS_SINE,
		Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	
	for leaf in leaves:
		if leaf:
			leaf.queue_free()
	queue_free()


func remove_leaf(leaf):
	var pos = leaf.global_position
	var i = leaves.find(leaf)
	n_leaves -= 1
	leaves[i] = null
	
	for leaf in leaves:
		if leaf:
			selected_leaf = leaf.selected()
			return
	die()


func _on_Leaf_died(leaf):
	if leaves.has(leaf):
		call_deferred("remove_leaf", leaf)


func _on_Tween_tween_completed(object, key):
	can_shoot = true


func _on_Lifetime_timeout():
	die()
