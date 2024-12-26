extends CanvasLayer

var options_scene = preload("res://scenes/ui/options_menu.tscn")
var meta_scene = preload("res://scenes/ui/meta_menu.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"%PlayButton".pressed.connect(on_play_pressed)
	$"%UpgradesButton".pressed.connect(on_upgrades_pressed)
	$"%OptionsButton".pressed.connect(on_options_pressed)
	$"%QuitButton".pressed.connect(on_quit_pressed)


func on_play_pressed():
	ScreenTransaction.transition()
	await ScreenTransaction.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/Main/main.tscn")
	
	
func on_upgrades_pressed():
	ScreenTransaction.transition()
	await ScreenTransaction.transitioned_halfway
	var meta_instance = meta_scene.instantiate()
	add_child(meta_instance)
	
	
func on_options_pressed():
	ScreenTransaction.transition()
	await ScreenTransaction.transitioned_halfway
	var options_instance = options_scene.instantiate()
	add_child(options_instance)
	options_instance.back_pressed.connect(on_options_closed.bind(options_instance))
	
	
func on_quit_pressed():
	get_tree().quit()


func on_options_closed(options_instance: Node):
	options_instance.queue_free()
