extends Node2D

@export var Rock: PackedScene

var screensize: Vector2 = Vector2()

func _ready():
	randomize()
	screensize = get_viewport().get_visible_rect().size
	$Player.screensize = screensize
	for i in range(3):
		spawn_rock(3)

"""
	when called with a size parameter, it picks a random position alogn the Rockpath
	and a random velocity. If those values are also provided, it will use them
	instead.
"""
func spawn_rock(size, pos=null, vel=null):
	if !pos:
		#$RockPath/RockSpawn.set_offset(randi())
		$RockPath/RockSpawn.h_offset = randi()
		$RockPath/RockSpawn.v_offset = randi()
		pos = $RockPath/RockSpawn.position
	if !vel:
		vel = Vector2(1, 0).rotated(
			randf_range(0, TAU)
		) * randi_range(100, 150)
		
	var r = Rock.instantiate()
	r.screensize = screensize
	r.start(pos, vel, size)
	#$Rocks.add_child(r)
	call_deferred("add_child", r)
	r.exploded.connect(_on_Rock_exploded)

func _on_player_shoot(bullet, pos, dir):
	var b = bullet.instantiate()
	b.start(pos, dir)
	add_child(b)

"""
	two new rocks are created unless the rock that was destroyed was the smallest
	size it can be. The offset loop variable will ensure that they spawn and travel
	in opposite directions (negative and positive). The dir variable finds the vector
	between the player and the rock, then uses tangent() to find the perpendicular
	to that vector. This ensures that the new rock travel away from the player.
"""
func _on_Rock_exploded(size, radius, pos, vel):
	if size <= 1:
		return
	for offset in [-1, 1]:
		#var dir = (pos - $Player.position).normalized().tangent() * offset
		var dir = (pos - $Player.position).normalized()
		var tangent = Vector2(-dir.y, dir.x) * offset
		#var newpos = pos + dir * radius
		var newpos = pos + tangent * radius
		var newvel = dir * vel.length() * 2.1
		spawn_rock(size-1, newpos, newvel)
