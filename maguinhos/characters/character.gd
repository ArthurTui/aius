extends KinematicBody2D

const RUN_SPEED = 4
const DASH_SPEED = 8

enum ELEMENT {
	fire,
	water,
	lightning,
	nature
}

signal death

#var input_states = preload("res://input_states.gd")

# We use the port, because actions are named ending on port,
# and port - device_id association is made on the InputMap before
# each game.
var controller_port = 0

#var btn_magic = input_states.new(KEY_SPACE)
#var btn_melee = input_states.new(name_adapter("char_melee"))

var current_anim = "idle_down"
var character_name = "skeleton"

var current_direction = Vector2(0, 1)
var current_element
var current_color
var current_spell
var current_level
var charge

var ready_to_spell = true
var holding_spell = false
var is_stunned = false
var is_rooted = false
var is_dashing = false
var can_dash = true

var active_spell
var slow_multiplier = 1
var push_direction = Vector2(0, 0)
var dash_direction = Vector2(0, 0)

var health = 100

var activation_wait = 0


# Spells

# Fire
var fire1 = preload("res://spells/fire/fire1.tscn")
var fire2 = preload("res://spells/fire/fire2.tscn")
var fire3 = preload("res://spells/fire/fire3.tscn")
var fire_charge = [30, 90, 1]
var fire_cd = [.2, .5, 1.5]

# Water
var water1 = preload("res://spells/water/water_level1.tscn")
var water2 = preload("res://spells/water/water_level2.tscn")
var water3 = preload("res://spells/water/water_level3.tscn")
var water_charge = [40, 50, 1]
var water_cd = [.7, 1, 1.5]

# Lightning
var lightning1 = preload("res://spells/lightning/lightning1.tscn")
var lightning2 = preload("res://spells/lightning/lightning_level2.tscn")
var lightning3 = preload("res://spells/lightning/lightning_level3.tscn")
var lightning_charge = [60, 90, 1]
var lightning_cd = [0.6, 0.8, 1]

# Nature
var nature1 = preload("res://spells/nature/nature1.tscn")
var nature2 = preload("res://spells/nature/nature2.tscn")
var nature3 = preload("res://spells/nature/nature3.tscn")
var nature_charge = [40, 40, 1]
var nature_cd = [0.4, 0.6, 0.8]

# Spells in the form spell[element][level]
var spells = [[fire1, fire2, fire3], [water1, water2, water3],
		[lightning1, lightning2, lightning3], [nature1, nature2, nature3]]

var max_charge = [fire_charge, water_charge, lightning_charge, nature_charge]
var cooldown = [fire_cd, water_cd, lightning_cd, nature_cd]


func _ready():
	add_to_group("Player")
	
	# This is a port test.
	# The reassingment of btn_magic (and other future buttons)
	# may be necessary, though, because we only know of ports
	# after the game has started.
	# Having an _init would also be wise, for we may construct
	# the battle scene manually later.
	
	var node_name = self.get_name()
	controller_port = node_name.substr(node_name.length() - 1, node_name.length()).to_int()
	
	
	change_element(ELEMENT.fire)
	
	
	var frames_src = "res://characters/sprites/%s.tres" % character_name
	$sprite.frames = load(frames_src)


func _process(delta):
	
	# Movement
	
	var direction = Vector2(0, 0)
	var new_anim
	var mot
	
	if !is_stunned:
		# determines movement
		if Input.is_action_pressed(str("p", controller_port, "_move_left")):
		    direction -= Vector2( 1, 0 )
		if Input.is_action_pressed(str("p", controller_port, "_move_right")):
		    direction += Vector2( 1, 0 )
		if Input.is_action_pressed(str("p", controller_port, "_move_down")):
		    direction += Vector2( 0, 1 )
		if Input.is_action_pressed(str("p", controller_port, "_move_up")):
		    direction -= Vector2( 0, 1 )
	
		if direction == Vector2( 0, 0 ):
			new_anim = str("idle_", current_anim.split("_")[1])
		else:
			current_direction = direction
			new_anim = define_animation(current_direction)
		
		# applies the determined movement
		if !is_rooted:
			# if dash is not on cooldown
			if can_dash and Input.is_action_just_pressed(str("p", controller_port, "_dash")):
				is_dashing = true
				can_dash = false
				dash_direction = direction
				# Disables collision with spells.
				# We may need to add another shape so that the
				# character still collides with structures
				# when dashing
				$shape.set_disabled(true)
				$sprite.set_self_modulate(Color(1,1,1,0.5))
				$sprite/glow.set_self_modulate(Color(1,1,1,0.5))
				$dash_timer.start()
			if not is_dashing:
				mot = move_and_collide(direction.normalized()*RUN_SPEED*slow_multiplier + push_direction)
			else:
				mot = move_and_collide(dash_direction.normalized()*DASH_SPEED*slow_multiplier)
				
		if !holding_spell:
			if Input.is_action_pressed(str("p", controller_port, "_element_fire")):
			    change_element(ELEMENT.fire)
			if Input.is_action_pressed(str("p", controller_port, "_element_water")):
			    change_element(ELEMENT.water)
			if Input.is_action_pressed(str("p", controller_port, "_element_lightning")):
			    change_element(ELEMENT.lightning)
			if Input.is_action_pressed(str("p", controller_port, "_element_nature")):
			    change_element(ELEMENT.nature)
		
		if ready_to_spell and charge > 0:
			var action = str("p", controller_port, "_btn_magic")
			if not Input.is_action_pressed(action) or Input.is_action_just_released(action):
				if active_spell == null:
					release_spell()
				elif active_spell.has_activation:
					active_spell.activate()
		update_animation(new_anim)


func _physics_process(delta):
	if !is_stunned:
		if Input.is_action_pressed(str("p", controller_port, "_btn_magic")):
			if active_spell == null:
				charge += 1
				$charge_bar.set_value(charge)
				if charge >= $charge_bar.get_max(): # Bar maxed out
					if not $charge_bar/anim.is_playing():
						$charge_bar/anim.play("pulse")
					update_max_charge()
			elif activation_wait >= 5:
				active_spell.activate()
				activation_wait = 0
			else:
				activation_wait += 1
		if $cooldown_bar.visible:
			$cooldown_bar.value -= 1


func change_element(element):
	if current_element == element:
		return
	
	var colors = [Color(1, 0, 0), Color(0, 0, 1), Color(1, 1, 0), Color(0, 1, 0)]
	
	current_color = colors[element]
	if not is_dashing:
		$sprite/glow.set_self_modulate(current_color)
	current_element = element
	charge = 0
	current_level = 0
	$charge_bar.set_value(0)
	$charge_bar.set_max(max_charge[element][0])


func update_max_charge():
	if current_level >= 2:
		return
	
	current_level += 1
	charge = 0
	$charge_bar.set_max(max_charge[current_element][current_level])


func release_spell():
	var spell = spells[current_element][current_level]
	var projectile = spell.instance()
	projectile.fire(current_direction.normalized(), self)
	get_parent().add_child(projectile)

	# Resets spell
	ready_to_spell = false
	current_spell = spell
	if projectile.has_activation:
		holding_spell = true
		active_spell = projectile
	else:
		spell_ended()


func spell_ended():
	set_cooldown(cooldown[current_element][current_level])
	holding_spell = false
	current_spell = null
	active_spell = null


func set_cooldown(time):
	$cooldown_timer.set_wait_time(time)
	$cooldown_timer.start()

	# Display cooldown bar
	$charge_bar.hide()
	$cooldown_bar.show()
	$cooldown_bar.set_max(time * 60)
	$cooldown_bar.set_value($cooldown_bar.get_max())


# Spell cooldown is over
func _on_cooldown_timeout():
	charge = 0
	current_level = 0
	ready_to_spell = true

	$cooldown_bar.hide()
	$charge_bar.set_value(0)
	$charge_bar.set_max(max_charge[current_element][0])
	$charge_bar.show()


func slow(time, multiplier):
	slow_multiplier = multiplier
	$slow_timer.set_wait_time(time)
	$slow_timer.start()


func stun(time):
	is_stunned = true
	update_animation(str("idle_", current_anim.split("_")[1]))
	$stun_timer.set_wait_time(time)
	$stun_timer.start()


func root(time):
	is_rooted = true
	$root_timer.set_wait_time(time)
	$root_timer.start()


# Slow time is over
func _on_slow_timeout():
	slow_multiplier = 1


# Stun time is over
func _on_stun_timeout():
	is_stunned = false


# Root time is over
func _on_root_timeout():
	is_rooted = false

# Duration of the dash
func _on_dash_timer_timeout():
	is_dashing = false
	dash_direction = Vector2(0, 0)
	$shape.set_disabled(false)
	$sprite.set_self_modulate(Color(1,1,1,1))
	$sprite/glow.set_self_modulate(current_color)
	$dash_cd.start()


# Time until dash can be used again
func _on_dash_cd_timeout():
	can_dash = true


func take_damage(damage, kb_dir, kb_str = 0):
	health -= damage
	$health_bar.set_value(health)
	if health <= 0:
		die()
	if kb_dir != null: # Knockback
		set_position(self.position + kb_dir * kb_str)


func die():
	emit_signal("death")
	queue_free()


func define_animation(direction):
	var animation = "walk_"
	
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

	if new_animation != current_anim and not is_dashing:
		$sprite.play(new_animation)
		$sprite/glow.play(new_animation)
		current_anim = new_animation


# Function that adds controller_port to the end of
# the name srnt, so that it can be understood by
# the input map.
func name_adapter(name):
	return str(name, "_", controller_port)
