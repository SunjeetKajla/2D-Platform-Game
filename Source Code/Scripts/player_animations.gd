extends Node

# Animation helper for player character
# This script manages all player animations and transitions

@onready var animated_sprite: AnimatedSprite2D = get_parent().get_node("AnimatedSprite2D")
@onready var player: CharacterBody2D = get_parent()

var current_animation = ""

func _ready():
	if not animated_sprite:
		create_animated_sprite()
	setup_animations()

func create_animated_sprite():
	animated_sprite = AnimatedSprite2D.new()
	player.add_child(animated_sprite)
	animated_sprite.name = "AnimatedSprite2D"

func setup_animations():
	# Create sprite frames resource
	var sprite_frames = SpriteFrames.new()
	
	# Load character texture
	var character_texture = preload("res://Assets/Character.png")
	
	# Setup idle animation
	sprite_frames.add_animation("idle")
	sprite_frames.set_animation_speed("idle", 5.0)
	sprite_frames.set_animation_loop("idle", true)
	
	# Setup run animation
	sprite_frames.add_animation("run")
	sprite_frames.set_animation_speed("run", 10.0)
	sprite_frames.set_animation_loop("run", true)
	
	# Setup jump animation
	sprite_frames.add_animation("jump")
	sprite_frames.set_animation_speed("jump", 5.0)
	sprite_frames.set_animation_loop("jump", false)
	
	# Setup fall animation
	sprite_frames.add_animation("fall")
	sprite_frames.set_animation_speed("fall", 5.0)
	sprite_frames.set_animation_loop("fall", false)
	
	# Setup slide animation
	sprite_frames.add_animation("slide")
	sprite_frames.set_animation_speed("slide", 8.0)
	sprite_frames.set_animation_loop("slide", true)
	
	# Setup wall slide animation
	sprite_frames.add_animation("wall_slide")
	sprite_frames.set_animation_speed("wall_slide", 3.0)
	sprite_frames.set_animation_loop("wall_slide", true)
	
	# Add frames (using single texture for now, can be expanded with sprite sheets)
	for anim in ["idle", "run", "jump", "fall", "slide", "wall_slide"]:
		sprite_frames.add_frame(anim, character_texture)
	
	animated_sprite.sprite_frames = sprite_frames

func play_animation(animation_name: String):
	if current_animation != animation_name:
		current_animation = animation_name
		animated_sprite.play(animation_name)

func get_current_animation() -> String:
	return current_animation