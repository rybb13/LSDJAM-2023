extends CharacterBody3D

@export var move_speed = 8.0
@export var move_acceleration = 50.0
@export var move_deceleration = 45.0
@export var gravity_scale = 1.0

@onready var anim_sprite = get_node("PlayerAnimSprite")

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

func _physics_process(delta: float):
	apply_gravity(gravity_scale, delta)
	
	# Get 3d direction from 2d input
	var move_direction = (transform.basis * Vector3(input.x, 0.0, input.y)).normalized()
	
	apply_movement(move_direction, move_speed, move_acceleration, move_deceleration, delta)
	
	move_and_slide()

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
	var right_pressed = Input.is_action_pressed("Right")
	var right_just_pressed = Input.is_action_just_pressed("Right")
	var left_pressed = Input.is_action_pressed("Left")
	var left_just_pressed = Input.is_action_just_pressed("Left")
	var up_pressed = Input.is_action_pressed("Up")
	var up_just_pressed = Input.is_action_just_pressed("Up")
	var down_pressed = Input.is_action_pressed("Down")
	var down_just_pressed = Input.is_action_just_pressed("Down")
	
	if right_pressed or left_pressed or up_pressed or down_pressed:
		if right_just_pressed:
			mode = Mode.Walk
			direction = Direction.Right
		elif left_just_pressed:
			mode = Mode.Walk
			direction = Direction.Left
		elif up_just_pressed:
			mode = Mode.Walk
			direction = Direction.Up
		elif down_just_pressed:
			mode = Mode.Walk
			direction = Direction.Down
	else:
		mode = Mode.Stand
	
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
