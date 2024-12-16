extends RigidBody2D

signal shoot

var screensize = Vector2()

# enum is short for enumeration, is a short convenient way to create a set of constants
#const INIT = 0
#const ALIVE = 1
#const INVULNERABLE = 2
#const DEAD = 3
# you can also assign a name to an enum which is useful for when you
# have more than one collection of constants in a single script.
enum {INIT, ALIVE, INVULNERABLE, DEAD}
var state = null

# movement variables
@export var engine_power: int
@export var spin_power: int
var max_speed: Vector2 = Vector2(5000, 0)

# bullet variables
@export var Bullet: PackedScene
@export var fire_rate: float

var can_shoot = true

# thrust will represent the force being applied by the ship's engine
# either (0, 0) when coasting, or a vector with the length of engine_power when powered on.
var thrust = Vector2()

# represents what direction the ship is turning in and applies a torque or rotational force.
var rotation_dir = 0

func _ready():
	screensize = get_viewport().get_visible_rect().size
	$GunTimer.wait_time = fire_rate
	change_state(ALIVE)
	
func change_state(new_state):
	match new_state:
		INIT:
			$CollisionShape2D.call_deferred("set_disabled", true)
		ALIVE:
			$CollisionShape2D.call_deferred("set_disabled", false)
		INVULNERABLE:
			$CollisionShape2D.call_deferred("set_disabled", true)
		DEAD:
			$CollisionShape2D.call_deferred("set_disabled", true)
	
	state = new_state

func _process(_delta):
	get_input()
	
func get_input():
	thrust = Vector2()
	if state in [DEAD, INIT]:
		return
	if Input.is_action_pressed("thrust"):
		thrust = Vector2(engine_power, 0)
	rotation_dir = 0
	if Input.is_action_pressed("rotate_right"):
		rotation_dir += 1
	if Input.is_action_pressed("rotate_left"):
		rotation_dir -= 1
	
	# shooting
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot_bullet()
		
	linear_velocity.clamp(Vector2.ZERO, max_speed)
		
func shoot_bullet():
	if state == INVULNERABLE:
		return
	emit_signal("shoot", Bullet, $Muzzle.global_position, rotation)
	can_shoot = false
	$GunTimer.start()


"""
	A transform matrix represents one or more transformations in 2D space such
	as translation, rotation, and/or scaling. Translation (position) information
	is found by accessing the origin property of Transform2D.
"""
func _integrate_forces(physics_state):
	# Apply forces and torques
	physics_state.apply_force(thrust.rotated(rotation))
	physics_state.apply_torque(spin_power * rotation_dir)
	
	# get the current position from the physics state
	var transform_position = physics_state.transform.origin
	
	# Screen wrap logic
	if transform_position.x > screensize.x:
		transform_position.x = 0
	elif transform_position.x < 0:
		transform_position.x = screensize.x
		
	if transform_position.y > screensize.y:
		transform_position.y = 0
	elif transform_position.y < 0:
		transform_position.y = screensize.y
		
	# Update the body's transform
	var new_transform = physics_state.transform
	new_transform.origin = transform_position
	physics_state.transform = new_transform
	

func _on_gun_timer_timeout():
	can_shoot = true
