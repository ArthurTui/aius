extends Node2D

const MIN_Y = 0
const MAX_Y = 1080

func _ready():
	pass


func spawn():
	$Polygon2D.position.y = rand_range(MIN_Y, MAX_Y)
	$Polygon2D.visible = true
	$Polygon2D/Mid/CollisionShape2D.disabled = true
	$Active.start()


func despawn():
	print($Polygon2D/Area.get_overlapping_bodies())
	for body in $Polygon2D/Area.get_overlapping_bodies():
		print(body)
		if body.collision_layer == 1: # Character
			return
	$Polygon2D.visible = false
	$Polygon2D/Mid/CollisionShape2D.disabled = false
	$Inactive.start()


func _on_Active_timeout():
	despawn()


func _on_Inactive_timeout():
	spawn()


func _on_Area_body_exited(body):
	print("_on_Area_body_exited")
	$Timer.start()
	yield($Timer, "timeout")
	despawn()
