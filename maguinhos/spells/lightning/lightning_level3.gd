extends "res://spells/base_spell.gd"

const DAMAGE = 20
var element = 0 # Lightning = 0, Nature = 1, Fire = 2, Water = 3
var level = 3

var parent


#func _ready():
#	get_node( "SFX" ).play( "thunder" )


func fire( direction, parent ):
	self.parent = parent
	get_node( "AnimatedSprite" ).set_frame(0)
	set_rotation( direction.angle() - deg2rad(90))
	set_position( parent.position )
	get_node( "AnimationPlayer" ).play( "fire" )


# Damages and stuns if target is an enemy
func _on_Area2D_body_enter( body ):
	if body != parent:
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE, null)
			body.stun(1.5)


func die():
	queue_free()


func free_scn():
	queue_free()