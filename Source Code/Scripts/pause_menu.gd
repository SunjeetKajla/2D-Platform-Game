extends Control

@onready var game_manager: Node = %GameManager

func _ready():
	visible = false

func show_pause_menu():
	visible = true

func hide_pause_menu():
	visible = false

func _on_resume_button_pressed():
	hide_pause_menu()
	game_manager.resume_game()

func _on_restart_button_pressed():
	game_manager.resume_game()
	game_manager.restart_level()

func _on_home_button_pressed():
	game_manager.resume_game()
	get_tree().change_scene_to_file("res://Scenes/home_screen.tscn")