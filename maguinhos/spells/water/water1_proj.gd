extends "res://spells/base_spell.gd"

func fire(caster, direction, speed, damage, knockback):
	self.caster = caster
	$Projectile.caster = caster
	self.direction = direction
	$Sprite.rotation = direction.angle()
	self.speed = speed
	self.damage = damage
	self.knockback = knockback
	connect("shake_screen", caster.get_parent().get_parent(), "shake_screen")


func _process(delta):
	position += direction * speed


func on_hit(character):
	.on_hit(character)
	emit_signal("shake_screen", shake)


func die():
	if $Tween.is_active():
		return
	$Projectile/Shape.disabled = true
	set_process(false)
	
	var dur = .4
	$Tween.interpolate_property($Sprite, "scale", Vector2(.15, .15),
		Vector2(.5, .5), dur, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.interpolate_property($Sprite, "modulate", Color(1, 1, 1, 1),
		Color(1, 1, 1, 0), dur, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.interpolate_property($Shadow, "scale", $Shadow.scale,
		$Shadow.scale * 3.33, dur, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.interpolate_property($Shadow, "modulate", $Shadow.modulate,
		Color(0, 0, 0, 0), dur, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()
	yield($Tween, "tween_completed")
	queue_free()
