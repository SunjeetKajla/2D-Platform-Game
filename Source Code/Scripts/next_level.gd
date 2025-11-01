extends Area2D

@onready var message_label: Label = null

func _ready():
	message_label = Label.new()
	add_child(message_label)
	message_label.top_level = true
	message_label.position = Vector2(-80, -40)
	message_label.text = ""
	message_label.modulate = Color.RED

func _on_body_entered(body):
	if body.name == "Player":
		var game_manager = get_tree().get_first_node_in_group("game_manager")
		if game_manager and game_manager.coins_collected >= game_manager.total_coins:
			body.velocity.y = -700
			SoundManager.play_sfx("power_up")
			await get_tree().create_timer(1.0).timeout
			game_manager.complete_level()
		else:
			message_label.global_position = global_position + Vector2(-80, -40)
			message_label.text = "Collect all coins to go to next stage"
			await get_tree().create_timer(2.0).timeout
			message_label.text = ""
