extends "res://spells/base_spell.gd"


func cast(caster, direction):
	.cast(caster, direction)
	$Projectile.caster = caster
	set_position(caster.position)
	set_rotation(direction.angle())


func _process(delta):
	if !dying:
		# Update position
		position += direction * speed
	
	# Update trail
	$Trail.global_position = Vector2()
	$Trail.add_point(global_position + Vector2())
	if $Trail.get_point_count() > 10:
		$Trail.remove_point(0)


func die():
	.die()
	$Projectile/Shape.disabled = true
	$Lifetime.stop()
	death_animation()


func death_animation():
	# Animation duration
	var dur = .4
	
	$DeathTween.interpolate_property($Sprite, "scale", $Sprite.scale,
		Vector2(1.5, 1.5), dur, Tween.TRANS_QUAD, Tween.EASE_IN)
	$DeathTween.interpolate_property($Sprite, "modulate", $Sprite.modulate,
		Color(1, 1, 1, 0), dur, Tween.TRANS_QUAD, Tween.EASE_IN)
	$DeathTween.start()


func _on_Lifetime_timeout():
	die()


func _on_DeathTween_tween_completed(object, key):
	queue_free()
