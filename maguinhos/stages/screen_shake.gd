extends Position2D

const DEBUG = 1

# Values of positional and rotational offsets when the screen shake is at its
# maximum
const MAX_ANGLE = 5
const MAX_OFFSET_X = 20
const MAX_OFFSET_Y = 20

# The ratio at which the screen shake decreases. It is multiplied by dt in
# process, so screen_shake goes from 1 to 0 in 1 / DEC_RATIO seconds.
const DEC_RATIO = 1.5

# The expoent when factoring screen shake into the actual position and rotation
# offsets. Suggested value is between 2 and 3.
const EXP = 2

# A value representing current screen shake factor ranging from 0 to 1.
var screen_shake = 0
var shake_factor = 0

func _ready():
	randomize()

func _process(delta):
	if DEBUG:
		if Input.is_action_just_released("d100_element_fire"):
			add_shake(.25)
		if Input.is_action_just_released("d100_element_water"):
			add_shake(.5)
		if Input.is_action_just_released("d100_element_lightning"):
			add_shake(.75)
		if Input.is_action_just_released("d100_element_nature"):
			add_shake(1)
	
	shake_factor = pow(screen_shake, EXP)
	
	if DEBUG:
		get_parent().get_node("HelpHUD/VBox/ShakeBar").value = screen_shake
		get_parent().get_node("HelpHUD/VBox/FactorBar").value = shake_factor
	
	var x = rand_range(-1, 1) * shake_factor * MAX_OFFSET_X
	var y = rand_range(-1, 1) * shake_factor * MAX_OFFSET_Y
	position = Vector2(x, y)
	rotation_degrees = rand_range(-1, 1) * shake_factor * MAX_ANGLE
	
	screen_shake = max(0, screen_shake - DEC_RATIO * delta)

func add_shake(shake):
	screen_shake = min(1, screen_shake + shake)
