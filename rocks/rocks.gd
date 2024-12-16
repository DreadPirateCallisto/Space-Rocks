extends RigidBody2D

signal exploded

var screensize: Vector2 = Vector2()

"""
	big rocks size = 3
	medium rocks size = 2
	small rocks size = 1
"""
var size
var radius

# multiplied by size to set the sprite's scale, collision radius, and so on
var scale_factor = 0.2

func start(pos, vel, _size):
	position = pos
	size = _size
	mass = 1.5 * size
	$Sprite2D.scale = Vector2(1, 1) * scale_factor * size
	radius = int($Sprite2D.texture.get_size().x/2 * scale_factor * size)
	$CollisionShape2D.shape = CircleShape2D.new()
	$CollisionShape2D.shape.radius = radius
	linear_velocity = vel
	angular_velocity = randf_range(-1.5, 1.5)
	$Explosion.scale = Vector2(0.75, 0.75) * size
	
func explode():
	z_index = 1
	$Sprite2D.hide()
	$Explosion/AnimationPlayer.play("explosion")
	#await $Explosion/AnimationPlayer.animation_finished
	emit_signal("exploded", size, radius, position,linear_velocity)
	angular_velocity = 0
	
	
func _integrate_forces(physics_state):
	# get the current position from the physics state
	var transform_position = physics_state.transform.origin
	
	 # Screen wrap logic
	# including radius results in smoother-looking teleportation
	if transform_position.x > screensize.x + radius:
		transform_position.x = 0 - radius
	elif transform_position.x < 0 - radius:
		transform_position.x = screensize.x + radius
		
	if transform_position.y > screensize.y + radius:
		transform_position.y = 0 - radius
	elif transform_position.y < 0 - radius:
		transform_position.y = screensize.y + radius
		
	# Update the body's transform
	var new_transform = physics_state.transform
	new_transform.origin = transform_position
	physics_state.transform = new_transform


func _on_animation_player_animation_finished(_anim_name):
	queue_free()
