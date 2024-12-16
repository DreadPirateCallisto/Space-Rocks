extends Node2D


func _on_player_shoot(bullet, pos, dir):
	var b = bullet.instantiate()
	b.start(pos, dir)
	add_child(b)
