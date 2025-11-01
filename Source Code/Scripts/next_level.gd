extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		body.velocity.y = -700
		await get_tree().create_timer(1.0).timeout
		var current_scene_file = get_tree().current_scene.scene_file_path
		var next_level_number = current_scene_file.to_int() + 1
		var next_level_path = "res://Scenes/level_" + str(next_level_number) + ".tscn"
		get_tree().change_scene_to_file(next_level_path)
