extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("You Died!!")
		SoundManager.play_sfx("hurt")
		Engine.time_scale = 0.8
		body.get_node("CollisionShape2D").queue_free()
		timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.player_died()
	else:
		get_tree().reload_current_scene()
