extends Node

# Audio players for different sound categories
@onready var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var ambient_player: AudioStreamPlayer = AudioStreamPlayer.new()

# Sound effects
var jump_sound = preload("res://Assets/sounds/jump.wav")
var land_sound = preload("res://Assets/sounds/tap.wav")
var coin_sound = preload("res://Assets/sounds/coin.wav")
var hurt_sound = preload("res://Assets/sounds/hurt.wav")
var power_up_sound = preload("res://Assets/sounds/power_up.wav")
var explosion_sound = preload("res://Assets/sounds/explosion.wav")

# Music
var background_music = preload("res://Assets/music/time_for_adventure.mp3")

# Volume settings
var master_volume = 1.0
var sfx_volume = 0.8
var music_volume = 0.6
var ambient_volume = 0.4

func _ready():
	# Setup audio players
	add_child(sfx_player)
	add_child(music_player)
	add_child(ambient_player)
	
	# Configure audio buses
	sfx_player.bus = "SFX"
	music_player.bus = "Music"
	ambient_player.bus = "Ambient"
	
	# Set volumes
	sfx_player.volume_db = linear_to_db(sfx_volume)
	music_player.volume_db = linear_to_db(music_volume)
	ambient_player.volume_db = linear_to_db(ambient_volume)
	
	# Setup music
	music_player.stream = background_music
	music_player.autoplay = true

func play_sfx(sound_name: String):
	var sound_stream = null
	
	match sound_name:
		"jump":
			sound_stream = jump_sound
		"land":
			sound_stream = land_sound
		"coin":
			sound_stream = coin_sound
		"hurt":
			sound_stream = hurt_sound
		"power_up":
			sound_stream = power_up_sound
		"explosion":
			sound_stream = explosion_sound
	
	if sound_stream:
		sfx_player.stream = sound_stream
		sfx_player.play()

func play_music(music_stream: AudioStream = null):
	if music_stream:
		music_player.stream = music_stream
	music_player.play()

func stop_music():
	music_player.stop()

func set_master_volume(volume: float):
	master_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))

func set_sfx_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)
	sfx_player.volume_db = linear_to_db(sfx_volume)

func set_music_volume(volume: float):
	music_volume = clamp(volume, 0.0, 1.0)
	music_player.volume_db = linear_to_db(music_volume)