extends Node3D

var active_enemies := []
var in_position_enemies := []

var nav_obsticles := []

var player

var reparented = false

func _physics_process(_delta):
	#if !reparented: 
	#	if get_tree().get_root().find_child("Map_01",true,false).find_child("NavigationRegion3D",false,false):
	#		reparent(get_tree().get_root().find_child("Map_01",true,false).find_child("NavigationRegion3D",false,false),true)
	#		reparented = true
	
	if !player:
		player = get_tree().get_root().find_child("World",false,false).find_child("Player",false,false)
	if Engine.get_physics_frames()% 6 == 0:
		active_enemy_updater()
	if Engine.get_physics_frames()% 12 == 0:
		in_position_enemy_updater()


func active_enemy_updater():
		for enemy in active_enemies:
			if enemy.position.distance_squared_to(player.position) < enemy.ATTACK_RANGE*enemy.ATTACK_RANGE:
				if enemy.can_attack(player):
					if in_position_enemies.find(enemy) == -1:
						active_enemies.remove_at(active_enemies.find(enemy))
						in_position_enemies.append(enemy)
					if !enemy.solid:
						enemy_turn_off(enemy)
			
			
			#var target_location = enemy.global_position + (player.global_position - enemy.global_position)-enemy.personal_eltolas
			
			if enemy.nav_agent.target_position == Vector3(0,0,0):
				enemy.update_target_location(player.global_position)
			
			
			if enemy.nav_agent.target_position != player.global_position:
				enemy.update_target_location(player.global_position)
			
			
			if !enemy.nav_agent.is_target_reached() and !enemy.nav_agent.is_navigation_finished() :
				enemy.update_target_location(player.global_position)
				moving_enemy(enemy)
			else:
				if in_position_enemies.find(enemy) == -1:
					active_enemies.remove_at(active_enemies.find(enemy))
					in_position_enemies.append(enemy)
				if !enemy.solid:
					enemy_turn_off(enemy)


func moving_enemy(enemy):
	var raw_velocity = (enemy.nav_agent.get_next_path_position() - enemy.global_transform.origin).normalized() * enemy.SPEED 
	#var raw_delta_velocity = (enemy.nav_agent.get_next_path_position() - enemy.global_transform.origin).normalized() * enemy.SPEED * get_physics_process_delta_time()
	enemy.nav_agent.set_velocity(raw_velocity)
	#enemy.position += (enemy.nav_agent.get_next_path_position() - enemy.global_transform.origin).normalized() * enemy.SPEED * get_physics_process_delta_time()


func enemy_turn_on(enemy):
	enemy.solid = false
	for array in nav_obsticles:
		if array.find(enemy) != -1:
			NavigationServer3D.free_rid(array[1])
			nav_obsticles.remove_at(nav_obsticles.find(array))
	#enemy.nav_agent.radius = 0.3
	enemy.in_pos_timer = 0.0
	enemy.in_pos_complete = false
	enemy.nav_agent.avoidance_enabled = true


func enemy_turn_off(enemy):
	enemy.solid = true
	
	var new_obstacle_rid: RID = NavigationServer3D.obstacle_create()
	var default_3d_map_rid: RID = get_world_3d().get_navigation_map()
	
	NavigationServer3D.obstacle_set_map(new_obstacle_rid, default_3d_map_rid)
	NavigationServer3D.obstacle_set_position(new_obstacle_rid, enemy.global_position)
	NavigationServer3D.obstacle_set_radius(new_obstacle_rid, .1)
	NavigationServer3D.obstacle_set_velocity(new_obstacle_rid,Vector3.ZERO)
	
	var outline = PackedVector3Array([Vector3(-.1, 0, -.1), Vector3(.1, 0, -.1), Vector3(.1, 0, .1), Vector3(-.1, 0, .1)])
	NavigationServer3D.obstacle_set_vertices(new_obstacle_rid, outline)
	NavigationServer3D.obstacle_set_height(new_obstacle_rid, 1.0)
	
	@warning_ignore("incompatible_ternary")
	@warning_ignore("narrowing_conversion")
	NavigationServer3D.obstacle_set_avoidance_layers(new_obstacle_rid,pow(2,2-1))
	NavigationServer3D.obstacle_set_avoidance_enabled(new_obstacle_rid, true)
	
	nav_obsticles.append([enemy,new_obstacle_rid])
	#enemy.nav_agent.radius = 0.01
	enemy.nav_agent.avoidance_enabled = false


func in_position_enemy_updater():
	for enemy in in_position_enemies:
		if !enemy.in_pos_complete:
			if enemy.in_pos_timer < 0.3:
				enemy.in_pos_timer += get_physics_process_delta_time()*12
			else:
				for array in nav_obsticles:
					if array.find(enemy) != -1:
						NavigationServer3D.free_rid(array[1])
						nav_obsticles.remove_at(nav_obsticles.find(array))
						enemy.in_pos_complete = true
			enemy.nav_agent.set_velocity(Vector3(0,0,0))
		enemy.rotation.y = lerp_angle(enemy.rotation.y, atan2(-enemy.position.direction_to(player.position).x,-enemy.position.direction_to(player.position).z),get_physics_process_delta_time()*10)

		if enemy.position.distance_squared_to(player.position) < enemy.ATTACK_RANGE*enemy.ATTACK_RANGE:
			if !enemy.can_attack(player):
				enemy_pause_release(enemy)
		else:
			enemy_pause_release(enemy)

func enemy_pause_release(enemy):
	if enemy.nav_agent.target_position != player.global_position:
		if in_position_enemies.find(enemy) != -1:
			if enemy.solid:
				enemy_turn_on(enemy)
			in_position_enemies.remove_at(in_position_enemies.find(enemy))
			active_enemies.append(enemy)
