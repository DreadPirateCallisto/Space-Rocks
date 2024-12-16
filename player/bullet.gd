extends Area2D

@export var speed: int
var velocity = Vector2()

func start(pos, dir):
	position = pos
	rotation = dir
	velocity = Vector2(speed, 0).rotated(dir)
	
func _process(delta):
	position += velocity * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_Bullet_body_entered(body):
	if body.is_in_group('rocks'):
		body.explode()
		queue_free()
