extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const WALL_JUMP_VELOCITY = -250.0
const WALL_SLIDE_SPEED = 50.0
const SLIDE_SPEED = 200.0
const SLIDE_DURATION = 0.5

var is_wall_sliding = false
var is_sliding = false
var slide_timer = 0.0
var coyote_time = 0.1
var coyote_timer = 0.0
var jump_buffer_time = 0.1
var jump_buffer_timer = 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var land_sound: AudioStreamPlayer2D = $LandSound
@onready var slide_sound: AudioStreamPlayer2D = $SlideSound
@onready var game_manager: Node = %GameManager

func _ready():
	add_to_group("player")
	if not animated_sprite:
		animated_sprite = AnimatedSprite2D.new()
		add_child(animated_sprite)
	setup_audio()

func setup_audio():
	if not jump_sound:
		jump_sound = AudioStreamPlayer2D.new()
		add_child(jump_sound)
		jump_sound.stream = preload("res://Assets/sounds/jump.wav")
	if not land_sound:
		land_sound = AudioStreamPlayer2D.new()
		add_child(land_sound)
		land_sound.stream = preload("res://Assets/sounds/tap.wav")
	if not slide_sound:
		slide_sound = AudioStreamPlayer2D.new()
		add_child(slide_sound)
		slide_sound.stream = preload("res://Assets/sounds/tap.wav")

func _physics_process(delta: float) -> void:
	update_timers(delta)
	handle_gravity(delta)
	handle_input()
	handle_movement()
	handle_animations()
	move_and_slide()

func update_timers(delta: float):
	if coyote_timer > 0:
		coyote_timer -= delta
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	if slide_timer > 0:
		slide_timer -= delta
	else:
		is_sliding = false

func handle_gravity(delta: float):
	if not is_on_floor():
		if is_on_wall_only() and velocity.y > 0:
			is_wall_sliding = true
			velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
		else:
			is_wall_sliding = false
			velocity += get_gravity() * delta
	else:
		is_wall_sliding = false
		if coyote_timer <= 0:
			coyote_timer = coyote_time

func handle_input():
	# Jump input
	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer_time
	
	# Slide input
	if Input.is_action_just_pressed("slide") or Input.is_action_just_pressed("ui_down") and is_on_floor():
		start_slide()

func handle_movement():
	var direction := Input.get_axis("move_left", "move_right")
	if direction == 0:
		direction = Input.get_axis("ui_left", "ui_right")
	
	# Handle jumping
	if jump_buffer_timer > 0 and (is_on_floor() or coyote_timer > 0 or is_wall_sliding):
		perform_jump(direction)
		jump_buffer_timer = 0
	
	# Handle horizontal movement
	if is_sliding:
		velocity.x = SLIDE_SPEED * (1 if animated_sprite.flip_h else -1)
	elif direction:
		velocity.x = direction * SPEED
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func perform_jump(direction: float):
	if is_wall_sliding:
		# Wall jump
		velocity.y = WALL_JUMP_VELOCITY
		velocity.x = -get_wall_normal().x * SPEED * 1.2
		animated_sprite.flip_h = get_wall_normal().x > 0
	else:
		# Normal jump
		velocity.y = JUMP_VELOCITY
	
	SoundManager.play_sfx("jump")
	coyote_timer = 0

func start_slide():
	if not is_sliding:
		is_sliding = true
		slide_timer = SLIDE_DURATION
		SoundManager.play_sfx("land")

func handle_animations():
	if is_sliding:
		animated_sprite.play("slide")
	elif is_wall_sliding:
		animated_sprite.play("wall_slide")
	elif not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
	elif abs(velocity.x) > 0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")

func _on_kill_zone_body_entered(body):
	if body == self:
		game_manager.player_died()
