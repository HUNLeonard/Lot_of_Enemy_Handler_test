extends Node3D

var navigation_mesh: NavigationMesh
var source_geometry : NavigationMeshSourceGeometryData3D
var callback_parsing : Callable
var callback_baking : Callable
var region_rid: RID

var spawns := []
var unchecked_spawn := []

var enemy_pool := []

@export_category("Enemies")
@export var Ground_Meele_Basic : PackedScene
@export var Ground_Shooting_Basic : PackedScene
@export var Air_Shooting_Basic : PackedScene
@export var Air_Melee_Basic : PackedScene

@export var Ground_Melee_Brute : PackedScene
@export var Ground_Shooting_Brute : PackedScene
@export var Air_Melee_Brute : PackedScene
@export var Air_Shooting_Brute : PackedScene

@export var Miniboss_1 : PackedScene
@export var Miniboss_2 : PackedScene
@export var Miniboss_3 : PackedScene
@export var Miniboss_4 : PackedScene

@export var Boss_1 : PackedScene
@export var Boss_2 : PackedScene
@export var Boss_3 : PackedScene
@export var Boss_4 : PackedScene

@export var Final_Boss : PackedScene


@export_category("Enemy Spawn Chances")
@export var Ground_Meele_Basic_Chance = 0
@export var Ground_Shooting_Basic_Chance = 0
@export var Air_Shooting_Basic_Chance = 0
@export var Air_Meele_Basic_Chance = 0

@export var Ground_Meele_Brute_Chance = 0
@export var Ground_Shooting_Brute_Chance = 0
@export var Air_Meele_Brute_Chance = 0
@export var Air_Shooting_Brute_Chance = 0

@export var Miniboss_1_Chance = 0
@export var Miniboss_2_Chance = 0
@export var Miniboss_3_Chance = 0
@export var Miniboss_4_Chance = 0

@export var Boss_1_Chance = 0
@export var Boss_2_Chance = 0
@export var Boss_3_Chance = 0
@export var Boss_4_Chance = 0

@export var Final_Boss_Chance = 0


func _ready() -> void:
	for spawn in get_children(false):
		spawns.append(spawn)


func fill_pool(pool_size):
	for i in range(pool_size):
		enemy_pool.append(next_enemy())


func next_enemy():
	# TODO Enemy Random Chance
	return Ground_Meele_Basic.instantiate()


func enemy_spawn():
	if enemy_pool.size():
		var valid_spawn = check_spawn_valid()
		if valid_spawn != null:
			get_tree().get_root().find_child("AE",false,false).add_child(enemy_pool[enemy_pool.size()-1])
			enemy_pool[enemy_pool.size()-1].position = valid_spawn.position + Vector3(0,enemy_pool[enemy_pool.size()-1].mesh.height,0)
			AE.active_enemies.append(enemy_pool[enemy_pool.size()-1])
			enemy_pool.remove_at(enemy_pool.size()-1)



func random_spawn():
	randomize()
	unchecked_spawn.shuffle()
	var random_spawn_picked = unchecked_spawn[unchecked_spawn.size()-1]
	unchecked_spawn.remove_at(unchecked_spawn.size()-1)
	return random_spawn_picked


func spawn_shape_checker(checking_spawn):
	var spawnShape := BoxShape3D.new()
	spawnShape.size = Vector3(1,1,1)
	
	var query_parameters = PhysicsShapeQueryParameters3D.new()
	
	query_parameters.set_shape(spawnShape)
	query_parameters.collide_with_bodies = true
	query_parameters.collision_mask = pow(2,2-1)
	query_parameters.margin = 0.04
	query_parameters.transform = checking_spawn.global_transform

	var space_state = get_world_3d().direct_space_state
	
	return space_state.get_rest_info(query_parameters)


func check_spawn_valid():
	unchecked_spawn.append_array(spawns)
	var spawnable : Node3D = random_spawn()
	for i in range(spawns.size()):
		var player = get_tree().get_root().find_child("World",false,false).find_child("Player",false,false)
		if spawnable.global_position.distance_to(player.global_position) < 1.0:
			spawnable = random_spawn()
		#if spawn_shape_checker(spawnable).size() > 0:
		#	spawnable = random_spawn()
			#print("Collision detected with ", intersected_bodies["collider"].name)
		else:
			return spawnable
	return null
	
func parse_source_geometry() -> void:
	source_geometry.clear()
	var root_node: Node3D = self

	# Parse the geometry from all mesh child nodes of the root node by default.
	NavigationServer3D.parse_source_geometry_data(
		navigation_mesh,
		source_geometry,
		root_node,
		callback_parsing
	)

func on_parsing_done() -> void:
	# Bake the navigation mesh on a thread with the source geometry data.
	NavigationServer3D.bake_from_source_geometry_data_async(
		navigation_mesh,
		source_geometry,
		callback_baking
	)

func on_baking_done() -> void:
	# Update the region with the updated navigation mesh.
	NavigationServer3D.region_set_navigation_mesh(region_rid, navigation_mesh)
