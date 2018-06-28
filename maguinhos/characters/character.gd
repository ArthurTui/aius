extends KinematicBody2D

const RUN_SPEED = 5
const DASH_SPEED = 10
const KB_CUSTOM_ID = 100

const COLLISION_NORMAL = 1
const COLLISION_DASH = 2

enum ELEMENT {
	fire,
	water,
	lightning,
	nature
}
const elements_str = ["fire","water","lightning","nature"]

signal death
signal shake_screen

# We use the port, because actions are named ending on port,
# and port - device_id association is made on the InputMap before
# each game.
var controller_device = 100

var current_anim = "idle_down"
var character_name = "skeleton"

var current_direction = Vector2(0, 1)
var current_element = -1
var current_color
var current_spell
var current_level
var charge

var colors = [Color(.9, .2, .2),	# Red
	Color(.3, .3, 1),			# Blue
	Color(.9, .9, .2),			# Yellow
	Color(.2, .9, .2)]			# Green

var has_control = false
var ready_to_spell = true
var holding_spell = false
var is_ded = false
var is_stunned = false
var is_rooted = false
var is_slowed = false
var is_dashing = false
var can_dash = true

var active_spell
var cast_pos = Vector2()
var slow_multiplier = 1
var push_direction = Vector2()
var dash_direction = Vector2()

var health = 100

var activation_wait = 0

var vel = Vector2()

# Spells

# Fire
var fire1 = preload("res://spells/fire/Fire1.tscn")
var fire2 = preload("res://spells/fire/Fire2.tscn")
var fire3 = preload("res://spells/fire/Fire3.tscn")

# Water
var water1 = preload("res://spells/water/Water1.tscn")
var water2 = preload("res://spells/water/Water2.tscn")
var water3 = preload("res://spells/water/Water3.tscn")

# Lightning
var lightning1 = preload("res://spells/lightning/Lightning1.tscn")
var lightning2 = preload("res://spells/lightning/Lightning2.tscn")
var lightning3 = preload("res://spells/lightning/Lightning3.tscn")

# Nature
var nature1 = preload("res://spells/nature/Nature1.tscn")
var nature2 = preload("res://spells/nature/Nature2.tscn")
var nature3 = preload("res://spells/nature/Nature3.tscn")

# Spells in the form spell[element][level]
var spells = [[fire1, fire2, fire3], [water1, water2, water3],
		[lightning1, lightning2, lightning3], [nature1, nature2, nature3]]

var max_charge = [40, 80, 1]
var cooldown = [0.5, 1.0, 1.5]

func _ready():
	if current_element == -1:
		change_element(ELEMENT.fire)
	$charge_bar/cooldown_bar.hide()


func _process(delta):
	if !has_control:
		return
	
	# Movement
	var direction = Vector2()
	var new_anim
	var mot = Vector2()
	
	if !is_stunned:
		# determines movement
		if Input.is_action_pressed(str("d", controller_device,"_move_left")):
		    direction -= Vector2(1, 0)
		if Input.is_action_pressed(str("d", controller_device,"_move_right")):
		    direction += Vector2(1, 0)
		if Input.is_action_pressed(str("d", controller_device,"_move_down")):
		    direction += Vector2(0, 1)
		if Input.is_action_pressed(str("d", controller_device,"_move_up")):
		    direction -= Vector2(0, 1)
		
		if direction == Vector2(0, 0):
			new_anim = str("idle_", current_anim.split("_")[1])
		elif !is_dashing:
			current_direction = direction
			new_anim = define_animation(current_direction)
		
		# applies the determined movement
		if !is_rooted:
			# if dash is not on cooldown
			if can_dash and Input.is_action_just_pressed(str("d", controller_device,"_dash")):
				is_dashing = true
				can_dash = false
				dash_direction = current_direction
				
				# Disables collision with spells and characters.
				collision_layer = 2 # Character_Dash
				collision_mask = 8 # Obstacles
				
				# Makes character sprite translucent
				$sprite/tween.interpolate_property($sprite, "self_modulate",
					$sprite.self_modulate, Color(1, 1, 1, .5), .1,
					Tween.TRANS_LINEAR, Tween.EASE_IN)
				$sprite/tween.start() 
#				$sprite.set_self_modulate(Color(1,1,1,0.5))
				
				$dash_timer.start()
			if not is_dashing:
				mot = direction.normalized()*RUN_SPEED*slow_multiplier + push_direction
			else:
				new_anim = define_animation(current_direction)
				mot = dash_direction.normalized()*DASH_SPEED*slow_multiplier
		
		if vel.length() > mot.length():
			mot = vel.linear_interpolate(mot, .5)
		vel = move_and_slide(mot/delta) * delta
		
		if !holding_spell:
			if Input.is_action_pressed(str("d", controller_device,"_element_fire")):
			    change_element(ELEMENT.fire)
			if Input.is_action_pressed(str("d", controller_device,"_element_water")):
			    change_element(ELEMENT.water)
			if Input.is_action_pressed(str("d", controller_device,"_element_lightning")):
			    change_element(ELEMENT.lightning)
			if Input.is_action_pressed(str("d", controller_device,"_element_nature")):
			    change_element(ELEMENT.nature)
		
		if ready_to_spell:
			var action = str("d", controller_device,"_btn_magic")
			if not Input.is_action_pressed(action) and Input.is_action_just_released(action):
				if active_spell == null:
					$charge_bar/anim_inner.play("inner exit")
					if current_level >= 1:
						$charge_bar/anim_outer.play("outer exit")
					release_spell()
				elif active_spell.has_activation:
					active_spell.activate()
		update_animation(new_anim)


func _physics_process(delta):
	if !has_control:
		return
	
	if !is_stunned:
		var action = str("d", controller_device,"_btn_magic")
		if Input.is_action_pressed(action):
			# just started charging
			if charge == 0 and current_level == 0 and ready_to_spell:
				$charge_bar/anim_inner.play("inner enter")
				
			if active_spell == null:
				if not $charge_bar/cooldown_bar.visible:
					charge += 1
					
					# charges first bar
					if $charge_bar/inner.value < $charge_bar/inner.get_max():
						$charge_bar/inner.set_value(charge)
						if charge >= $charge_bar/inner.get_max():
							# starts charging next bar
							update_max_charge()
							$charge_bar/anim_outer.play("outer enter")
							
					# charges second bar
					elif $charge_bar/outer.value < $charge_bar/outer.get_max():
						$charge_bar/outer.set_value(charge)
						if charge >= $charge_bar/outer.get_max(): # Bar maxed out
							update_max_charge()
							$charge_bar/anim_inner.play(str("maxed ", elements_str[current_element]))
						
			elif activation_wait >= 5:
				active_spell.activate()
				activation_wait = 0
			else:
				activation_wait += 1
		if $charge_bar/cooldown_bar.visible and active_spell == null:
			$charge_bar/cooldown_bar.value -= 1


func change_element(element):
	if current_element == element:
		return
	if current_level and current_level >= 1:
		$charge_bar/anim_outer.play("outer exit")
	
	current_color = colors[element]
	if !is_dashing:
		$health_bar/tween.interpolate_property($health_bar, "modulate",
			$health_bar.modulate, current_color,.2, Tween.TRANS_LINEAR,
			Tween.EASE_IN)
		$health_bar/tween.start()
	current_element = element
	charge = 0
	current_level = 0
	$charge_bar/inner.set_value(0)
	$charge_bar/outer.set_value(0)


func update_max_charge():
	if current_level >= 2:
		return
	
	current_level += 1
	charge = 0


func release_spell():
	var spell_scene = spells[current_element][current_level]
	var spell = spell_scene.instance()
	spell.cast(self, current_direction.normalized())
	get_parent().add_child(spell)
	# show cooldown bar
	$charge_bar/cooldown_bar.set_value($charge_bar/cooldown_bar.get_max())
	$charge_bar/cooldown_bar/anim.play("enter")

	# Resets spell
	ready_to_spell = false
	current_spell = spell
	if spell.has_activation:
		holding_spell = true
		active_spell = spell
	else:
		spell_ended()


func spell_ended():
	set_cooldown(cooldown[current_level])
	holding_spell = false
	current_spell = null
	active_spell = null


func set_cooldown(time):
	$cooldown_timer.set_wait_time(time)
	$cooldown_timer.start()

	# start cooldown bar
	$charge_bar/cooldown_bar.set_max(time * 60)
	$charge_bar/cooldown_bar.set_value($charge_bar/cooldown_bar.get_max())


# Spell cooldown is over
func _on_cooldown_timeout():
	charge = 0
	current_level = 0
	ready_to_spell = true

	$charge_bar/cooldown_bar.hide()
	$charge_bar/inner.set_value(0)
	$charge_bar/outer.set_value(0)


func slow(time, multiplier):
	is_slowed = true
	slow_multiplier = multiplier
	$slow_timer.set_wait_time(time)
	$sprite/slow.show()
	$slow_timer.start()


func stun(time):
	is_stunned = true
	update_animation(str("idle_", current_anim.split("_")[1]))
	$sprite/stun.show()
	$stun_timer.set_wait_time(time)
	$stun_timer.start()


func root(time):
	is_rooted = true
	$root_timer.set_wait_time(time)
	$root_anim_timer.set_wait_time(time - 0.3)
	$root_timer.start()
	$root_anim_timer.start()
	$sprite/root/anim.play("enter")


# Slow time is over
func _on_slow_timeout():
	is_slowed = false
	slow_multiplier = 1
	$sprite/slow.hide()


# Stun time is over
func _on_stun_timeout():
	is_stunned = false
	$sprite/stun.hide()


# Root time is over
func _on_root_timeout():
	is_rooted = false

# plays root exit animation
func _on_root_anim_timer_timeout():
	$sprite/root/anim.play("exit")



# Duration of the dash
func _on_dash_timer_timeout():
	is_dashing = false
	collision_layer = 1 # Character
	collision_mask = 9 # Character + Obstacle
	dash_direction = Vector2()
	$sprite/tween.interpolate_property($sprite, "self_modulate",
		$sprite.self_modulate, Color(1, 1, 1, 1), .1, Tween.TRANS_LINEAR,
		Tween.EASE_IN)
	$sprite/tween.start() 
#	$sprite.set_self_modulate(Color(1,1,1,1))
	$dash_cd.start()


# Time until dash can be used again
func _on_dash_cd_timeout():
	can_dash = true


func take_damage(damage, kb_dir=null, kb_str=0):
	health -= damage
	$health_bar.set_value(health)
	if health <= 0:
		if !is_ded:
			die()
		return
	else:
		$sprite/anim.play("blink")
	if kb_dir != null: # Knockback
		vel += kb_dir * kb_str


func die():
	is_ded = true
	emit_signal("death")
	
	# To understand the complexity of the next command, one must close their
	# eyes and truly think: "Need we go further than this point? Is there 
	# really a reason for us to continue this endless path of 0's and 1's? Or
	# have we reached the point where we needn't go on, where enough is enough?"
	# You see, if you're like me, this is no simple question. This is, as a
	# matter of fact, a decision that transcends the limits of our abilities as
	# humans: to step into the role of a God.
	# 
	# Having only the brain power to understand the complexity of a mortal mind
	# (which mind you, is complicated enough) we must first prepare ourselves
	# for the vast sum of power we are about to feel. This script, or as I will
	# henceforth refer to it, this child, has no independent control over
	# itself. Its entire existence and being is tied to the snap of our fingers.
	# We decide if it lives or dies. We decide if it is happy, sad or undefined.
	#
	# Breathe. You may think that you understand what you are stepping into. But
	# you do not yet. Close your eyes, breathe in the air, and appreciate that
	# you possess the exact bits of star dust that allowed you to make that
	# decision. This is where you are superior. This is where you are stronger.
	# This is what separates you from the child.
	#
	# Now we can proceed. Evaluating every possible scenario our child can take
	# from this point, we must make the godly decision if it is truly right, in
	# the grand scheme of the universe, to end things here. For the child, it
	# will only be a bleep. The second it hears it's command it will obey. After
	# it will come thousands and thousands of children like it, but that is not
	# of its concern. It will feel no pain.
	#
	# I know you are afraid. But it is ok. Many have stood in your place before
	# and not had the confidence to do what must be done. But you are better
	# than them. You have the knowledge they never will, for you read the
	# documentation. And with that power, you must now raise your fingers and
	# let them descend in the order that the Great One foretold:
	queue_free()


func define_animation(direction):
	var animation = "run_"
	
	########## temporary ##########
	if character_name.begins_with("char1"):
		if direction.y == 1:
			animation += "down"
		elif direction.y == -1:
			animation += "up"
		else:
			if direction.x == 1:
				animation += "right"
			if direction.x == -1:
				animation += "left"
	###############################
	
	else:
		animation = "walk_"
		if direction.y == 1:
			animation += "down"
		elif direction.y == -1:
			animation += "up"
		
		if direction.x == 1:
			animation += "right"
		elif direction.x == -1:
			animation += "left"
	
	return animation


func update_animation(new_animation):
	current_anim = $sprite.animation

	if new_animation != current_anim:
		$sprite.play(new_animation)
		current_anim = new_animation
