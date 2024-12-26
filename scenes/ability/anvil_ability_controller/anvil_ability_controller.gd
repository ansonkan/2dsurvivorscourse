extends Node

const BASE_RANGE = 50
const BASE_DAMAGE = 15
const BASE_SEPERATION = 10

@export var anvil_ability_scene: PackedScene

var anvil_count = 0
var is_attacking = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.timeout.connect(on_timer_timerout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	
	
func on_timer_timerout():
	if is_attacking:
		return
	
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
		
	is_attacking = true
	
	var t = get_tree().create_tween()
	var direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var spawn_range = randf_range(0, BASE_RANGE)
	var initial_position = player.global_position
	for i in (anvil_count + 1):
		var distance = spawn_range + (i * BASE_SEPERATION)
		var spawn_position = initial_position + (direction * distance)
		
		t.tween_callback(spawn_anvil.bind(initial_position, spawn_position))
		t.tween_interval(0.1)
	t.chain()
	
	is_attacking = false


func spawn_anvil(initial_position: Vector2, spawn_position: Vector2):
	var query_parameters = PhysicsRayQueryParameters2D.create(initial_position, spawn_position, 1 << 0)
	var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
	if !result.is_empty():
		spawn_position = result["position"]
		
	var anvil_ability = anvil_ability_scene.instantiate() as AnvilAbility
	get_tree().get_first_node_in_group("foreground_layer").add_child(anvil_ability)
	anvil_ability.global_position = spawn_position
	anvil_ability.hitbox_component.damage = BASE_DAMAGE


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "anvil_count":
		anvil_count = current_upgrades["anvil_count"]["quantity"]
		
