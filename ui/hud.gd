extends CanvasLayer

# will be emitted when player clicks StartButton
signal start_game

# references to the three life counter images
@onready var lives_counter = [
	$MarginContainer/HBoxContainer/LivesCounter/L1,
	$MarginContainer/HBoxContainer/LivesCounter/L2,
	$MarginContainer/HBoxContainer/LivesCounter/L3
]

# changes to the display
func show_message(message):
	$MessageLabel.text = message
	$MessageLabel.show()
	$MessageTimer.start()

func update_score(value):
	$MarginContainer/HBoxContainer/ScoreLabel.text = str(value)
	
func update_lives(value):
	for item in range(3):
		lives_counter[item].visible = value > item

func game_over():
	show_message("Game Over")
	await $MessageTimer.timeout
	$StartButton.show()

func _on_start_button_pressed():
	$StartButton.hide()
	emit_signal("start_game")


func _on_message_timer_timeout():
	$MessageLabel.hide()
	$MessageLabel.text = ""
