extends Camera3D

@export var track_speed = Vector3(8.0, 3.5, 5.0)
# @export var track_min_offset = Vector3(0.0, 2.0, 2.75)
# @export var track_max_offset = Vector3(0.0, 2.0, 4.25)

@onready var track_target = get_node("../PlayerCharacterBody")

var offset = Vector3.ZERO

func _ready():
	offset = track_target.position - self.position
	# self.position = track_target.position + ((track_min_offset + track_max_offset) * 0.5)

func _process(delta: float):
	var source_position = track_target.position - offset
	#var hit = line_cast(track_target.position, self.position)
	
	#if hit["collider"] != null:
	#	source_position = hit["position"]
	
	self.position = source_position
	
	#var dif = self.position - track_target.position	
	
	#self.position = lerp3(self.position, track_target.position + clamp(dif, track_min_offset, track_max_offset), track_speed * delta)
	
func lerp3(a: Vector3, b: Vector3, x: Vector3) -> Vector3:
	return Vector3(
		lerp(a.x, b.x, x.x),
		lerp(a.y, b.y, x.y),
		lerp(a.z, b.z, x.z)
	)

func line_cast(a: Vector3, b: Vector3) -> Dictionary:
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	
	query.from = a
	query.to = b
	query.hit_back_faces = true
	query.hit_from_inside = true
	
	return space.intersect_ray(query)
