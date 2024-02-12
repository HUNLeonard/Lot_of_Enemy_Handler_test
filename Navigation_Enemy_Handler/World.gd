extends Node3D


func _ready():
	if has_node("Map_01/NavigationRegion3D/Spawns"):
		get_node("Map_01/NavigationRegion3D/Spawns").fill_pool(500)


func _on_enemy_spawn_timeout():
	if has_node("Map_01/NavigationRegion3D/Spawns"):
		get_node("Map_01/NavigationRegion3D/Spawns").enemy_spawn()
