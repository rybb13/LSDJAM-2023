extends Camera3D

@export var track_speed = Vector3(8.0, 3.5, 5.0)
@export var noise_speed = 0.2
@export var noise_scale = Vector3(0.2, 0.32, 0.35)

@onready var track_target = get_node("../PlayerCharacterBody")
@onready var track_target_collision = get_node("../PlayerCharacterBody/PlayerCollision")

var offset = Vector3.ZERO
var noise_script = preload("res://Module/Scripts/SoftNoise.gd")
var noise
var time = 0.0

func _ready():
	noise = noise_script.new().SoftNoise.new(0)
	
	offset = track_target.position - self.position

func _process(delta: float):
	#var new_position = clamp_depth(track_target.position, self.position, track_target.position - offset, Vector3(0.0, 0.0, 1.0), 2.5, 5.5)
	var new_position = track_target.position - offset
	var hit = line_cast(track_target.position, self.position)
	
	if hit.has("collider"):
		new_position.z = max(lerp(track_target.position.z, hit["position"].z, 0.9), track_target.position.z - offset.z * 0.5)
	
	new_position += calculate_noise_offset(self.position, time * noise_speed) * noise_scale
	
	self.position = lerp3(self.position, new_position, track_speed * delta)
	
	time += delta
	
func lerp3(a: Vector3, b: Vector3, x: Vector3) -> Vector3:
	return Vector3(
		lerp(a.x, b.x, x.x),
		lerp(a.y, b.y, x.y),
		lerp(a.z, b.z, x.z)
	)

func line_cast(a: Vector3, b: Vector3) -> Dictionary:
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	
	query.from = a.lerp(b, 0.1)
	query.to = b.lerp(a, 0.1)
	query.hit_back_faces = false
	query.hit_from_inside = false
	query.exclude = [ track_target_collision ]
	
	return space.intersect_ray(query, )

func clamp_depth(target: Vector3, source: Vector3, desired: Vector3, desired_vector: Vector3, min_depth: float, max_depth: float, offset: float = 0.1) -> Vector3:
	var result = desired
	var end = target + desired_vector * (target - source).length()
	var hit = line_cast(target, end)
	
	if hit.has("collider"):
		var hit_position = hit["position"] + (desired_vector * offset)
		var bound_a = target + desired_vector * min_depth
		var bound_b = target + desired_vector * max_depth
		var min_position = Vector3(min(bound_a.x, bound_b.x), min(bound_a.y, bound_b.y), min(bound_a.z, bound_b.z))
		var max_position = Vector3(max(bound_a.x, bound_b.x), max(bound_a.y, bound_b.y), max(bound_a.z, bound_b.z))
		
		print(hit_position)
		print(min_position)
		print(max_position)
		
		result = Vector3(
			clamp(hit_position.x, min_position.x, max_position.x),
			clamp(hit_position.y, min_position.y, max_position.y),
			clamp(hit_position.z, min_position.z, max_position.z)
		)
	
	return result

func calculate_noise_offset(input: Vector3, time: float) -> Vector3:
	return Vector3(
		clamp(noise.openSimplex2D(input.x, time) * 0.5 + 0.5, 0.0, 1.0),
		clamp(noise.openSimplex2D(input.y, time) * 0.5 + 0.5, 0.0, 1.0),
		clamp(noise.openSimplex2D(input.z, time) * 0.5 + 0.5, 0.0, 1.0)
	).normalized()
