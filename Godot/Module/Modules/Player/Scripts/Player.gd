extends CharacterBody3D

@export var grid_size = 0.1
@export var move_speed = 5.0
@export var move_acceleration = 50.0
@export var move_deceleration = 45.0
@export var gravity_scale = 1.0

@onready var anim_sprite = get_node("PlayerAnimSprite")
@onready var footstep_audio = get_node("PlayerFootstepAudio")

var pressed_keys: Array
var input = Vector2.ZERO
var default_gravity = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
var default_gravity_scale = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity = Vector3.ZERO
var mode = Mode.Stand
var direction = Direction.Down

enum Mode { Stand, Walk }
enum Direction { Right, Left, Up, Down }

func _read():
	update_sprite()

func _process(_delta: float):
	# Update input vector
	input = Input.get_vector("Left", "Right", "Up", "Down")
	
	update_mode_direction()
	update_input()
	update_sprite()
	check_anim_frame()

func _physics_process(delta: float):
	#self.global_position = saved_position
	
	apply_gravity(gravity_scale, delta)
	
	# Get 3d direction from 2d input
	var move_direction = (transform.basis * Vector3(input.x, 0.0, input.y)).normalized()
	
	apply_movement(move_direction, move_speed, move_acceleration, move_deceleration, delta)
	
	move_and_slide()
	
	snap_position(grid_size)

func has_input() -> bool:
	return input != Vector2.ZERO
	
func is_falling() -> bool:
	return not is_on_floor()

func apply_gravity(custom_scale: float, delta: float):
	if is_falling():
		gravity += default_gravity * default_gravity_scale * custom_scale * delta
		velocity += gravity
	else:
		gravity = Vector3.ZERO

func apply_acceleration(move_vector: Vector3, value: float, saved_gravity: Vector3, delta: float):
	velocity = velocity.move_toward(move_vector + saved_gravity, value * delta)

func apply_deceleration(value: float, saved_gravity: Vector3, delta: float):
	velocity = velocity.move_toward(Vector3.ZERO + saved_gravity, value * delta)

func apply_movement(direction: Vector3, speed: float, acceleration: float, deceleration: float, delta: float):
	if has_input():
		apply_acceleration(direction * speed, acceleration, gravity, delta)
	else:
		apply_deceleration(deceleration, gravity, delta)

func update_mode_direction():
	for key in [ "Right", "Left", "Up", "Down" ]:
		var direction = Direction.get(key)
		
		if Input.is_action_just_pressed(key) && !pressed_keys.has(direction):
			pressed_keys.push_back(direction)
		
		if Input.is_action_just_released(key) && pressed_keys.has(direction):
			pressed_keys.erase(direction)
	
	if pressed_keys.is_empty():
		mode = Mode.Stand
	else:
		mode = Mode.Walk
		direction = pressed_keys.back()
	
func get_anim_name(player_mode: Mode, player_direction: Direction) -> String:
	return Mode.keys()[player_mode] + Direction.keys()[player_direction]

func update_input():
	if mode == Mode.Walk:
		match direction:
			Direction.Right:
				input = Vector2(1.0, 0.0)
			Direction.Left:
				input = Vector2(-1.0, 0.0)
			Direction.Up:
				input = Vector2(0.0, -1.0)
			Direction.Down:
				input = Vector2(0.0, 1.0)
	else:
		input = Vector2(0.0, 0.0)

func update_sprite():
	anim_sprite.play(get_anim_name(mode, direction))

func check_anim_frame():
	var frame = anim_sprite.get_frame()
	
	if mode == Mode.Walk and (frame == 1 or frame == 5):
		footstep_audio.play()

func snap_position(size: float):
	var saved_velocity = self.velocity
	
	self.global_position.x = round(self.global_position.x / size) * size
	self.global_position.z = round(self.global_position.z / size) * size
	
	self.velocity = saved_velocity
