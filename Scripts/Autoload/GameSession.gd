extends Node

## Keeps the most recent level result available after its scene is closed.
var last_level_result: Dictionary = {}


func save_level_result(level_name: String, captured: int, spawned: int) -> void:
	last_level_result = {
		"level_name": level_name,
		"captured_ants": captured,
		"spawned_ants": spawned,
	}
