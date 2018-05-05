extends Node2D

const SPEED = 8
const ROTATION = 10
const DAMAGE = 5
const KNOCKBACK = 15

signal died(name)

var angle
var caster
var direction
var moving = false

func _ready():
	set_process(false)


func shoot(direction, caster):
	self.caster = caster
	$sprite.set_modulate(Color(1, 1, 1, 1))
	$lifetime.start()
	self.direction = direction
	moving = true
	set_process(true)


func _process(delta):
	if moving:
		update_pos()
	update_trail(position)


func update_pos():
	position += direction * SPEED
	rotation_degrees += ROTATION


func update_trail(position):
	$trail.global_position = Vector2()
	$trail.global_rotation = 0
	$trail.add_point($trail_pivot.global_position)
	if $trail.get_point_count() > 10:
		$trail.remove_point(0)


func _on_projectile_body_entered(body):
	# does damage if take damage function exists in body
	if body != caster:
		if body.has_method("take_damage"):
			var kb_direction = (body.position - position).normalized()
			body.take_damage(DAMAGE, kb_direction, KNOCKBACK)
		die()


func monitor():
	if has_node("projectile"):
		$projectile.monitoring = true
		$projectile.monitorable = true


func remove_area():
	if has_node("projectile"):
		$projectile.queue_free()


func die():
	if $anim.is_playing():
		return
	remove_area()
	moving = false
	emit_signal("died", get_name())
	$anim.play("death")
	yield($anim, "animation_finished")
	queue_free()


func selected():
	$sprite.set_modulate(Color(2, 5, 2, 1))


func _on_lifetime_timeout():
	die()
