extends "res://spells/base_spell.gd"

const SHIELD_RADIUS = 60

var can_shoot = false

func _ready():
	var angle = 0
	for leaf in $leaves.get_children():
		leaf.angle = angle
		leaf.set_rotation(rad2deg(angle))
		$tween.interpolate_property(leaf, "position", Vector2(), Vector2(SHIELD_RADIUS, 0).rotated(angle),
									.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
		angle -= PI/2
	$tween.start()
	$leaves.get_child(0).selected()


func fire(direction, caster):
	self.caster = caster
	set_position(caster.position)
	$rotation.play("spin")


func activate():
	if $leaves.get_child_count() > 0 and can_shoot:
		var leaf = $leaves.get_child(0)
		var pos = leaf.global_position
		$leaves.remove_child(leaf)
		get_parent().add_child(leaf)
		leaf.position = pos
		leaf.shoot(caster.current_direction.normalized())
		if ($leaves.get_child_count() > 0):
			$leaves.get_child(0).selected()
		else:
			die()


func _process(delta):
	if caster and !weakref(caster).get_ref(): # caster was freed
		caster = null
		die()
		return
	if caster:
		position = caster.position


func _on_lifetime_timeout():
	die()


func die():
	$lifetime.queue_free()
	if caster:
		caster.spell_ended()
	for leaf in $leaves.get_children():
		leaf.remove_area()
		$tween.interpolate_property(leaf, "position", leaf.position, Vector2(), .2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	if $leaves.get_child_count() > 0:
		$tween.start()
		yield($tween, "tween_completed")
	queue_free()


func _on_leaf_died(name):
	if not $leaves.has_node(name):
		return
	var leaf = $leaves.get_node(name)
	call_deferred("remove_leaf", leaf)
#	var pos = leaf.global_position
#	$leaves.call_deferred("remove_child", leaf)
#	get_parent().call_deferred("add_child", leaf)
#	leaf.position = pos
#	if $leaves.get_child_count() == 0:
#		die()


func remove_leaf(leaf):
	var pos = leaf.global_position
	$leaves.remove_child(leaf)
	get_parent().add_child(leaf)
	leaf.position = pos
	if $leaves.get_child_count() == 0:
		die()


func _on_tween_tween_completed(object, key):
	can_shoot = true
	for leaf in $leaves.get_children():
		leaf.monitor()
