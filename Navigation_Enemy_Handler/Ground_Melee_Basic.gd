extends MeshInstance3D

const SPEED = 5.0
const ATTACK_RANGE = 2.0

@onready var nav_agent : NavigationAgent3D= $NavigationAgent3D

var solid := false
var in_pos_timer := 0.0
var in_pos_complete := false

func enemy_delete():
	get_tree().get_root().find_child("AE",false,false).remove_child(self)
	if AE.active_enemies.find(self) != -1:
		AE.active_enemies.remove_at(AE.active_enemies.find(self))
	else:
		for array in AE.nav_obsticles:
			if array.find(self) != -1:
				NavigationServer3D.free_rid(array[1])
				AE.nav_obsticles.remove_at(AE.nav_obsticles.find(array))
		AE.in_position_enemies.remove_at(AE.in_position_enemies.find(self))

		
	

	


func can_attack(target):
	var space_state = get_world_3d().direct_space_state
	var origin = global_transform.origin
	var end = origin - global_transform.basis.z * ATTACK_RANGE
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_bodies = true
	query.hit_from_inside = true
	query.set_collision_mask(1) # Fal
	query.set_collision_mask(query.get_collision_mask() + 2) # Player
	var result = space_state.intersect_ray(query)
	if result:
		return result.collider == target
	return false


func update_target_location(target_location):
	nav_agent.target_position = target_location
	

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	if Engine.get_physics_frames()% 2 == 0:
		if !solid:
			var cur_vel = safe_velocity
			if is_there_a_wall(cur_vel):
				cur_vel = -Vector3(cur_vel.x,0,cur_vel.z)
			elif is_there_a_ledge(cur_vel):
				cur_vel = -Vector3(cur_vel.x,0,cur_vel.z)
				
			rotation.y = lerp_angle(rotation.y, atan2(-cur_vel.x,-cur_vel.z),get_physics_process_delta_time()*20)
			#look_at(Vector3(position.x + velocity.x,$MeshInstance3D.mesh.height,position.z + velocity.z))
			position += cur_vel * get_physics_process_delta_time() * 2
			#move_and_slide()


func is_there_a_ledge(vel):
	var space_state = get_world_3d().direct_space_state
	var origin = global_transform.origin
	var end = origin + Vector3(vel.x,0,vel.z).normalized() + Vector3(0,-mesh.height*1.25,0)
	#$ball.global_position = end
	var query2 = PhysicsRayQueryParameters3D.create(origin, end)
	query2.collide_with_bodies = true
	query2.hit_from_inside = true
	query2.set_collision_mask(1) # Fal
	
	var result2 = space_state.intersect_ray(query2)
	if result2:
		return false
	return true

func is_there_a_wall(vel):
	var space_state = get_world_3d().direct_space_state
	var origin = global_transform.origin
	var end = origin + Vector3(vel.x,0,vel.z).normalized()
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_bodies = true
	query.hit_from_inside = true
	query.set_collision_mask(1) # Fal

	
	var result = space_state.intersect_ray(query)
	if result:
		return true
	return false

