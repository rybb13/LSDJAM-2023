extends RigidBody3D

@export var track_speed = Vector3(8.0, 3.5, 5.0)
@export var track_min_offset = Vector3(0.0, 2.0, 2.75)
@export var track_max_offset = Vector3(0.0, 2.0, 4.25)
@export var noise_speed = 0.2
@export var noise_scale = Vector3(0.2, 0.32, 0.35)

@onready var track_target = get_node("../PlayerCharacterBody")
@onready var camera = get_node("CameraCollision/Camera")

var noise_script = preload("res://Module/Scripts/SoftNoise.gd")
var noise

var t = 0.0

func _ready():
	noise = noise_script.new().SoftNoise.new(0)
	
	self.position = track_target.position + ((track_min_offset + track_max_offset) * 0.5)

func _process(delta: float):
	var dif = self.position - track_target.position
	
	self.position = lerp3(self.position, track_target.position + clamp(dif, track_min_offset, track_max_offset), track_speed * delta)
	
	var noise_value = Vector3(
		clamp(noise.openSimplex2D(self.position.x, t * noise_speed) * 0.5 + 0.5, 0.0, 1.0),
		clamp(noise.openSimplex2D(self.position.y, t * noise_speed) * 0.5 + 0.5, 0.0, 1.0),
		clamp(noise.openSimplex2D(self.position.z, t * noise_speed) * 0.5 + 0.5, 0.0, 1.0)
	)
	var noise_offset = noise_value.normalized() * noise_scale
	camera.position = Vector3(noise_offset.x, noise_offset.y, noise_offset.z)
	
	t += delta
	
func lerp3(a: Vector3, b: Vector3, x: Vector3) -> Vector3:
	return Vector3(
		lerp(a.x, b.x, x.x),
		lerp(a.y, b.y, x.y),
		lerp(a.z, b.z, x.z)
	)
