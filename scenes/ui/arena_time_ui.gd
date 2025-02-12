extends CanvasLayer

@export var arena_time_manager: ArenaTimeManager
@onready var label = $"%Label"

func _process(delta):
	if arena_time_manager == null:
		return
	#var time_elapsed = format_seconds_to_string(arena_time_manager.get_time_elapsed())
	label.text = str(format_seconds_to_string(arena_time_manager.timer.time_left))


func format_seconds_to_string(seconds: float):
	var minutes = floor(seconds / 60)
	var remaining_seconds = seconds - (minutes * 60)
	return str(minutes) + ":" + ("%02d" % floor(remaining_seconds))
