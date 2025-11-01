extends Control

@onready var start_button: Button = $VBoxContainer/StartButton
@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var exit_button: Button = $VBoxContainer/ExitButton
@onready var stats_label: Label = $StatsLabel
@onready var background_music: AudioStreamPlayer = $BackgroundMusic

var game_manager_scene = preload("res://Scripts/game_manager.gd")
var save_exists = false

func _ready():
	check_save_file()
	update_stats_display()
	background_music.play()

func check_save_file():
	save_exists = FileAccess.file_exists("user://savegame.save")
	continue_button.disabled = not save_exists

func update_stats_display():
	if save_exists:
		var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
		var save_data = JSON.parse_string(save_file.get_as_text())
		save_file.close()
		
		if save_data and save_data.has("player_stats"):
			var stats = save_data.player_stats
			stats_label.text = "STATS\n" + \
				"Total Score: " + str(stats.get("total_score", 0)) + "\n" + \
				"Best Time: " + str(stats.get("best_time", 0.0)) + "s\n" + \
				"Deaths: " + str(stats.get("deaths", 0)) + "\n" + \
				"Levels Completed: " + str(stats.get("levels_completed", 0))
	else:
		stats_label.text = "STATS\nNo save data found"

func _on_start_button_pressed():
	# Delete save file to start fresh
	if FileAccess.file_exists("user://savegame.save"):
		DirAccess.remove_absolute("user://savegame.save")
	get_tree().change_scene_to_file("res://Scenes/level_1.tscn")

func _on_continue_button_pressed():
	if save_exists:
		var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
		var save_data = JSON.parse_string(save_file.get_as_text())
		save_file.close()
		
		if save_data:
			var current_level = save_data.get("current_level", 1)
			get_tree().change_scene_to_file("res://Scenes/level_" + str(current_level) + ".tscn")

func _on_exit_button_pressed():
	get_tree().quit()