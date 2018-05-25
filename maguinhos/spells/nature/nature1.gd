extends "res://spells/base_spell.gd"

const SHIELD_RADIUS = 100

var can_shoot = false

func _ready():
	var angle = 0
	for leaf in $Leaves.get_children():
		leaf.set_rotation(rad2deg(angle))
		$Tween.interpolate_property(leaf, "position", Vector2(),
			Vector2(SHIELD_RADIUS, 0).rotated(angle), .2, Tween.TRANS_SINE,
			Tween.EASE_OUT)
		angle -= PI/2
	$Tween.start()
	$Leaves.get_child(0).selected()


func cast(caster, direction):
	self.caster = caster
	self.direction = direction
	set_position(caster.position)


func activate():
	if $Leaves.get_child_count() > 0 and can_shoot:
		var leaf = $Leaves.get_child(0)
		var pos = leaf.global_position
		$Leaves.remove_child(leaf)
		get_parent().add_child(leaf)
		leaf.position = pos
		leaf.shoot(caster, caster.current_direction.normalized())
		if ($Leaves.get_child_count() > 0):
			$Leaves.get_child(0).selected()
		else:
			die()


func _process(delta):
	if !caster or !weakref(caster).get_ref(): # caster was freed
		caster = null
		die()
		return
	position = caster.position


func die():
	if dying:
		return
	.die()
	
	if caster and weakref(caster).get_ref():
		caster.spell_ended()
	
	for leaf in $Leaves.get_children():
		leaf.set_shape_disabled(true)
		$Tween.interpolate_property(leaf, "position", leaf.position, Vector2(),
			.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	if $Leaves.get_child_count() > 0:
		$Tween.start()
		yield($Tween, "tween_completed")
	
	queue_free()


func remove_leaf(leaf):
	var pos = leaf.global_position
	$Leaves.remove_child(leaf)
	get_parent().add_child(leaf)
	leaf.position = pos
	leaf.death_animation()
	if $Leaves.get_child_count() > 0:
		$Leaves.get_child(0).selected()
	else:
		die()


func _on_Leaf_died(leaf_name):
	if not $Leaves.has_node(leaf_name):
		return
	var leaf = $Leaves.get_node(leaf_name)
	call_deferred("remove_leaf", leaf)


func _on_Tween_tween_completed(object, key):
	can_shoot = true
	for leaf in $Leaves.get_children():
		leaf.set_shape_disabled(false)


func _on_Lifetime_timeout():
	die()
