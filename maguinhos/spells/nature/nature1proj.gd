extends "res://spells/base_spell.gd"

const ROTATION = 10

signal died(leaf)

func _ready():
	set_process(false)


func shoot(caster, direction):
	self.direction = direction
	
	$Sprite.set_modulate(Color(1, 1, 1, 1))
	$Lifetime.start()
	set_process(true)


func _process(delta):
	if !dying:
		update_pos()
	update_trail(position)


func update_pos():
	position += direction * speed
	$Sprite.rotation_degrees += ROTATION


func update_trail(position):
	$Trail.global_position = Vector2()
	$Trail.global_rotation = 0
	$Trail.add_point($Sprite/TrailPivot.global_position)
	if $Trail.get_point_count() > 10:
		$Trail.remove_point(0)


func selected():
	$Sprite.set_modulate(Color(2, 5, 2, 1))
	return self


func on_hit(character):
	.on_hit(character)
	emit_signal("shake_screen", shake)


func die():
	if dying:
		return
	.die()
	$Projectile/Shape.disabled = true
	$Sprite.modulate = Color(1, 1, 1, 1)
	emit_signal("died", self)
	death_animation()


func death_animation():
	# Animation duration
	var dur = .4
	
	$Tween.interpolate_property($Sprite, "scale", $Sprite.scale,
		Vector2(1.2, 1.2), dur, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.interpolate_property($Sprite, "modulate", $Sprite.modulate,
		Color(1, 1, 1, 0), dur, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.interpolate_property($Shadow, "scale", $Shadow.scale,
		1.2 * $Shadow.scale, dur, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.interpolate_property($Shadow, "modulate", $Shadow.modulate,
		Color(0, 0, 0, 0), dur, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.interpolate_property($Trail, "modulate", $Trail.modulate,
		Color(1, 1, 1, 0), dur, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()
	
	yield($Tween, "tween_completed")
	queue_free()


func _on_Lifetime_timeout():
	die()
