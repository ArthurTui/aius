extends KinematicBody2D

const RUN_SPEED = 4

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

var magic_element
var current_spell
var charge = 0
var current_spell_charge = 0
# Doesn't represent level 3. A level 3 spell is ready when
# this variable is 2 and chargeBar has a value >= max_charge
var current_spell_level = 1
var ready_to_spell = true
var holding_spell = false
var is_stunned = false
var is_rooted = false
var active_proj
var slow_multiplier = 1
var push_direction = Vector2(0, 0)

var health = 100

var wait = 0


# Spells

# Fire
var fire1 = preload("res://spells/fire/fire1.tscn")
var fire2 = preload("res://spells/fire/fire_level2.tscn")
var fire3 = preload("res://spells/fire/fire_level3.tscn")
var fire_charge = [30, 120]
var fire_cd = [.2, .5, 1.5]

# Water
var water1 = preload("res://spells/water/water_level1.tscn")
var water2 = preload("res://spells/water/water_level2.tscn")
var water3 = preload("res://spells/water/water_level3.tscn")
var water_charge = [40, 90]
var water_cd = [.7, 1, 1.5]

# Nature
var nature1 = preload("res://spells/nature/nature_level1.tscn")
var nature2 = preload("res://spells/nature/nature_level2.tscn")
var nature3 = preload("res://spells/nature/nature_level3.tscn")
var nature_charge = [40, 80]
var nature_cd = [0.4, 0.6, 0.8]

# Lightning
var lightning1 = preload("res://spells/lightning/lightning_level1.tscn")
var lightning2 = preload("res://spells/lightning/lightning_level2.tscn")
var lightning3 = preload("res://spells/lightning/lightning_level3.tscn")
var lightning_charge = [60, 150]
var lightning_cd = [0.6, 0.8, 1]

# Spells in the form spell[element][charge]
var spell = [[fire1, fire2, fire3], [water1, water2, water3],
		[lightning1, lightning2, lightning3], [nature1, nature2, nature3]]
# Charge times
#var charge = [[fire2.charge, fire3.charge], [water2.charge, water3.charge],
#		[lightning2.charge, lightning3.charge], [nature2.charge, nature3.charge]]


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
#	btn_magic = input_states.new(KEY_SPACE)

	change_element(ELEMENT.fire)
	$charge_bar.set_max(max_charge())
	
	
	var frames_src = "res://characters/sprites/%s.tres" % character_name
	$sprite.frames = load(frames_src)


func _process(delta):
	
	# Movement
	
	var direction = Vector2(0, 0)
	var new_anim
	
	if !is_stunned:
		if Input.is_key_pressed(KEY_LEFT):
			direction -= Vector2( 1, 0 )
		if Input.is_key_pressed(KEY_RIGHT):
			direction += Vector2( 1, 0 )
		if Input.is_key_pressed(KEY_DOWN):
			direction += Vector2( 0, 1 )
		if Input.is_key_pressed(KEY_UP):
			direction -= Vector2( 0, 1 )
	
		if direction == Vector2( 0, 0 ):
			new_anim = str("idle_", current_anim.split("_")[1])
		else:
			current_direction = direction
			new_anim = define_animation(current_direction)
		
		# should take external forces into consideration
		if !is_rooted:
			var mot = move_and_collide(direction.normalized()*RUN_SPEED*slow_multiplier + push_direction)
			
		if !holding_spell:
			if Input.is_key_pressed(KEY_1):
			    change_element(ELEMENT.fire)
			if Input.is_key_pressed(KEY_2):
			    change_element(ELEMENT.water)
			if Input.is_key_pressed(KEY_3):
			    change_element(ELEMENT.lightning)
			if Input.is_key_pressed(KEY_4):
			    change_element(ELEMENT.nature)
		
		if ready_to_spell and charge > 0:
			if not Input.is_action_pressed("btn_magic") or Input.is_action_just_released("btn_magic"):
				if active_proj == null:
					release_spell()
				else:
					active_proj.activate()
		update_animation(new_anim)


func _physics_process(delta):
	if !is_stunned:
		if Input.is_key_pressed(KEY_SPACE):
			if active_proj == null:
				charge += 1
				$charge_bar.set_value(charge - current_spell_charge)
				if $charge_bar.get_value() >= $charge_bar.get_max(): # Bar Maxed out
					if not $charge_bar/anim.is_playing():
						$charge_bar/anim.play("pulse")
					update_max_charge()
			elif wait >= 15:
				active_proj.activate()
				wait = 0
			else:
				wait += 1
		if $cooldown_bar.visible:
			$cooldown_bar.value -= 1


func change_element(element):
	if magic_element == element:
		return
	
	var colors = [Color(1, 0, 0), Color(0, 0, 1), Color(1, 1, 0), Color(0, 1, 0)]
	
	$sprite/glow.set_self_modulate(colors[element])
	magic_element = element
	charge = 0
	current_spell_charge = 0
	current_spell_level = 1
	$charge_bar.set_value(0)
	$charge_bar.set_max(max_charge())


func max_charge():
	var charge_index = 0
	if current_spell_charge != 0:
		charge_index = 1
	
	match magic_element:
		ELEMENT.fire:
			return fire_charge[charge_index]
		ELEMENT.water:
			return water_charge[charge_index]
		ELEMENT.nature:
			return nature_charge[charge_index]
		ELEMENT.lightning:
			return lightning_charge[charge_index]


func update_max_charge():
	if current_spell_level == 1:
		current_spell_charge = charge
		current_spell_level += 1
	$charge_bar.set_max(max_charge())


# Returns what spell is suposed to be cast depending on
# magic_element and charge
func define_spell():
	match magic_element:
		ELEMENT.fire:
			if charge < fire_charge[0]:
				return spell[ELEMENT.fire][0]
			elif charge < fire_charge[1]:
				return fire2
			return fire3
		ELEMENT.water:
			if charge < water_charge[0]:
				return water1
			elif charge < water_charge[1]:
				return water2
			return water3
		ELEMENT.nature:
			if charge < nature_charge[0]:
				return nature1
			elif charge < nature_charge[1]:
				return nature2
			return nature3
		ELEMENT.lightning:
			if charge < lightning_charge[0]:
				return lightning1
			elif charge < lightning_charge[1]:
				return lightning2
			return lightning3


# Returns correct cooldown(in seconds) for spell
func define_cooldown(spell):
	match magic_element:
		ELEMENT.fire:
			if spell == fire1:
				return fire_cd[0]
			elif spell == fire2:
				return fire_cd[1]
			return fire_cd[2]
		ELEMENT.water:
			if spell == water1:
				return water_cd[0]
			elif spell == water2:
				return water_cd[1]
			return water_cd[2]
		ELEMENT.nature:
			if spell == nature1:
				return nature_cd[0]
			elif spell == nature2:
				return nature_cd[1]
			return nature_cd[2]
		ELEMENT.lightning:
			if spell == lightning1:
				return lightning_cd[0]
			elif spell == lightning2:
				return lightning_cd[1]
			return lightning_cd[2]


func release_spell():
	var spell = define_spell()
	var projectile = spell.instance()
	projectile.fire(current_direction.normalized(), self)
	get_parent().add_child(projectile)

	# Resets spell
	ready_to_spell = false
	current_spell = spell
	if projectile.has_activation:
		holding_spell = true
		active_proj = projectile
	else:
		spell_ended()


func spell_ended():
	var cd = define_cooldown(current_spell)
	set_cooldown(cd)
	holding_spell = false
	current_spell = null
	active_proj = null


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
	current_spell_charge = 0
	current_spell_level = 1
	ready_to_spell = true

	$cooldown_bar.hide()
	$charge_bar.set_value(0)
	$charge_bar.set_max(max_charge())
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

	if new_animation != current_anim:
		$sprite.play(new_animation)
		$sprite/glow.play(new_animation)
		current_anim = new_animation


# Function that adds controller_port to the end of
# the name srnt, so that it can be understood by
# the input map.
func name_adapter(name):
	return str(name, "_", controller_port)

