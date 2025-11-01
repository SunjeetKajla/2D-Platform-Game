extends Node

enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }

var current_state = GameState.MENU
var score = 0
var coins_collected = 0
var total_coins = 10
var current_level = 1
var max_level = 3
var player_stats = {
	"total_score": 0,
	"best_time": 0.0,
	"deaths": 0,
	"levels_completed": 0
}
var level_start_time = 0.0

@onready var score_label: Label = $"ScoreLabel"
@onready var pause_menu: Control = null

signal state_changed(new_state)
signal level_completed
signal game_over

func _ready():
	add_to_group("game_manager")
	load_progress()
	level_start_time = Time.get_time_dict_from_system()["hour"] * 3600 + Time.get_time_dict_from_system()["minute"] * 60 + Time.get_time_dict_from_system()["second"]
	current_state = GameState.PLAYING
	# Find pause menu in scene
	pause_menu = get_node_or_null("../PauseMenu")
	if pause_menu:
		connect("state_changed", _on_state_changed)

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if current_state == GameState.PLAYING:
			pause_game()
		elif current_state == GameState.PAUSED:
			resume_game()

func _on_state_changed(new_state: GameState):
	if pause_menu:
		if new_state == GameState.PAUSED:
			pause_menu.show_pause_menu()
		else:
			pause_menu.hide_pause_menu()

func change_state(new_state: GameState):
	current_state = new_state
	state_changed.emit(new_state)

func start_game():
	change_state(GameState.PLAYING)

func pause_game():
	change_state(GameState.PAUSED)
	get_tree().paused = true

func resume_game():
	change_state(GameState.PLAYING)
	get_tree().paused = false

func exit_game():
	get_tree().quit()

func add_point():
	coins_collected += 1
	score += 10
	update_score_display()
	if coins_collected >= total_coins and current_level == 2:
		show_win_message()

func show_win_message():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var camera = player.get_node("Camera2D")
		var win_label = Label.new()
		camera.add_child(win_label)
		win_label.text = "You Win!!"
		win_label.modulate = Color.GREEN
		win_label.add_theme_font_size_override("font_size", 16)
		win_label.position = Vector2(-40, -60)
		win_label.size = Vector2(80, 30)
		var tween = create_tween()
		tween.tween_property(win_label, "modulate:a", 0.0, 3.0)
		tween.tween_callback(win_label.queue_free)

func set_level_coins(coins: int):
	total_coins = coins
	update_score_display()

func update_score_display():
	score_label.text = "Score: " + str(score) + "\nCoins: " + str(coins_collected) + "/" + str(total_coins)

func complete_level():
	var level_time = calculate_level_time()
	player_stats.levels_completed += 1
	player_stats.total_score += score
	if player_stats.best_time == 0.0 or level_time < player_stats.best_time:
		player_stats.best_time = level_time
	save_progress()
	level_completed.emit()
	next_level()

func calculate_level_time() -> float:
	var current_time = Time.get_time_dict_from_system()["hour"] * 3600 + Time.get_time_dict_from_system()["minute"] * 60 + Time.get_time_dict_from_system()["second"]
	return current_time - level_start_time

func next_level():
	if current_level < max_level:
		current_level += 1
		get_tree().change_scene_to_file("res://Scenes/level_" + str(current_level) + ".tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/home_screen.tscn")

func restart_level():
	get_tree().reload_current_scene()

func player_died():
	player_stats.deaths += 1
	restart_level()

func save_progress():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_data = {
		"current_level": current_level,
		"player_stats": player_stats
	}
	save_file.store_string(JSON.stringify(save_data))
	save_file.close()

func load_progress():
	if FileAccess.file_exists("user://savegame.save"):
		var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
		var save_data = JSON.parse_string(save_file.get_as_text())
		save_file.close()
		if save_data:
			current_level = save_data.get("current_level", 1)
			player_stats = save_data.get("player_stats", player_stats)
