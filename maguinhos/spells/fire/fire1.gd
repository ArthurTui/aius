extends "res://spells/base_spell.gd"

export (int) var SPEED
export (int) var DAMAGE
export (int) var KNOCKBACK

var direction = Vector2(0, 0)

func _ready():
	pass


func fire(direction, caster):
	self.direction = direction
	self.caster = caster
	$projectile.caster = caster
	set_position(caster.position)
	set_rotation(direction.angle())


func _process(delta):
	position += direction * SPEED
	$trail.scale.x = lerp($trail.scale.x, 1, .01)


func _on_projectile_body_entered(body):
	# does damage if take damage function exists in body
	if body != caster:
		if body.has_method("take_damage"):
			var kb_direction = (body.position - position).normalized()
			body.take_damage(DAMAGE, kb_direction, KNOCKBACK)
		die()


func _on_lifetime_timeout():
	die()


func die():
	if has_node("lifetime"):
		$lifetime.queue_free()
	if $anim.is_playing():
		return
	if has_node("projectile"):
		$projectile/shape.disabled = true
	$anim.play("death")
	$trail/tween.interpolate_property($trail, "scale", $trail.scale,
		$trail.scale * Vector2(0, 1), .4, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$trail/tween.interpolate_property($trail, "modulate", $trail.modulate,
		Color(1, 1, 1, 0), .4, Tween.TRANS_EXPO, Tween.EASE_OUT)
	$trail/tween.start()
	set_process(false)


func free_scn():
	queue_free()
