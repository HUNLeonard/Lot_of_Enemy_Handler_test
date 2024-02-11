extends MeshInstance3D

const SPEED = 5.0
const ATTACK_RANGE = 2.0

@onready var nav_agent : NavigationAgent3D= $NavigationAgent3D

var solid = false

func _ready():
	pass


func can_attack(target):
	var space_state = get_world_3d().direct_space_state
	var origin = global_transform.origin
	var end = target.global_transform.origin
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_bodies = true
	query.hit_from_inside = true
	query.set_collision_mask(1) # Fal
	query.set_collision_mask(query.get_collision_mask() + 2) # Player
	var result = space_state.intersect_ray(query)
	return result.collider == target


func update_target_location(target_location):
	nav_agent.target_position = target_location
	

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	if Engine.get_physics_frames()% 2 == 0:
		if !solid:
			var cur_vel = safe_velocity
			rotation.y = lerp_angle(rotation.y, atan2(-cur_vel.x,-cur_vel.z),get_physics_process_delta_time()*20)
			#look_at(Vector3(position.x + velocity.x,$MeshInstance3D.mesh.height,position.z + velocity.z))
			position += cur_vel * get_physics_process_delta_time() * 2
			#move_and_slide()

