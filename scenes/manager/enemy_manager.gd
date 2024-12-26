extends Node

const SPAWN_RADIUS = 370

@export var basic_enemy_scene: PackedScene
@export var wizard_enemy_scene: PackedScene
@export var bat_enemy_scene: PackedScene
@export var arena_time_manager: Node

@onready var timer = $Timer

var base_spawn_time = 0
var enemy_table = WeightedTable.new()
var number_to_spawn = 1
var max_enemies = 100
var chance_to_spawm_clusters = 0
var base_cluster_size = 10

func _ready() -> void:
	enemy_table.add_item(basic_enemy_scene, 10)
	base_spawn_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)


func get_spawn_position(check_offset: float = 20) -> Vector2:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return Vector2.ZERO
	
	var spawn_position = Vector2.ZERO
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	for i in 4:
		spawn_position = player.global_position + (random_direction * SPAWN_RADIUS)	
		var additional_check_offset = random_direction * check_offset
		
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position + additional_check_offset, 1 << 0)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
	
		if result.is_empty():
			break
		else:
			random_direction = random_direction.rotated(deg_to_rad(90))
			
	return spawn_position


func on_timer_timeout():
	timer.start()
	
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
		
	var enemies = get_tree().get_nodes_in_group("enemy")
	var spawn_quota = max(0, max_enemies - enemies.size())
	var basic_number_to_spawn = min(spawn_quota, number_to_spawn)
	
	for i in basic_number_to_spawn:
		spawn_enemy(enemy_table.pick_item() as PackedScene)
	
	var remaining_spawn_quota = max(spawn_quota - basic_number_to_spawn, 0)
	if remaining_spawn_quota > 0 && randf() <= chance_to_spawm_clusters:
		print("is spawning cluster!!! remaining_spawn_quota = %f" % remaining_spawn_quota)
		var cluster_position = get_spawn_position(40)
		print("cluster_position = %v" % cluster_position)
		
		var enemy_scene = enemy_table.pick_item() as PackedScene
		for i in base_cluster_size:
			var rand_dir = Vector2.RIGHT.rotated(randf_range(0, TAU))
			spawn_enemy(enemy_scene, cluster_position + (rand_dir * randf_range(0, 20)))


func spawn_enemy(enemy_scene: PackedScene, position: Vector2 = get_spawn_position()):
	var enemy = enemy_scene.instantiate() as Node2D
	
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	entities_layer.add_child(enemy)
	enemy.global_position = position


func on_arena_difficulty_increased(arena_difficulty: int):
	var time_off = (.1 / 12) * arena_difficulty
	time_off = min(time_off, .7)
	timer.wait_time = max(0.01, base_spawn_time - time_off)
	
	match arena_difficulty:
		2:
			enemy_table.add_item(wizard_enemy_scene, 1)
		3:
			enemy_table.add_item(wizard_enemy_scene, 1)
		4:
			enemy_table.add_item(wizard_enemy_scene, 1)
		5:
			enemy_table.add_item(wizard_enemy_scene, 2)
			enemy_table.add_item(bat_enemy_scene, 1)
		8:
			enemy_table.add_item(bat_enemy_scene, 1)
		15:
			enemy_table.add_item(wizard_enemy_scene, 5)
			enemy_table.add_item(bat_enemy_scene, 5)
			max_enemies = 150
		30:
			max_enemies = 200
			chance_to_spawm_clusters = 0.05
		45:
			chance_to_spawm_clusters = 0.1
			base_cluster_size = 50
		50:
			max_enemies = 300
			base_cluster_size = 100
			
	if (arena_difficulty % 2) == 0:
		number_to_spawn += 1
