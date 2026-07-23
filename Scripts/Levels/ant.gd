class_name AntLevel extends Node2D

@export_range(1.0, 60.0, 0.5) var level_duration_seconds := 15.0

@onready var bucket: Area2D = $Bucket
@onready var countdown_label: Label = $Countdown/BoxContainer/MarginContainer/HBoxContainer/current
@onready var background: Sprite2D = $Scenery/Background

var captured_ants := 0
var spawned_ants := 0
var _remaining_seconds := 0.0
var _is_running := false
var _active_ants: Dictionary = {}
var _spawn_components: Array[SpawnComponent] = []


func _ready() -> void:
	bucket.body_entered.connect(_on_bucket_body_entered)
	_spawn_components = _find_spawn_components()
	for spawn_component in _spawn_components:
		spawn_component.spawned.connect(_on_ant_spawned)
		spawn_component.start_spawning()
	get_viewport().size_changed.connect(_fit_background_to_viewport)
	_fit_background_to_viewport()
	_remaining_seconds = level_duration_seconds
	_is_running = true
	_update_countdown()


func _process(delta: float) -> void:
	if not _is_running:
		return
	_remaining_seconds = maxf(_remaining_seconds - delta, 0.0)
	_update_countdown()
	if is_zero_approx(_remaining_seconds):
		_finish_level()


func _find_spawn_components() -> Array[SpawnComponent]:
	var components: Array[SpawnComponent] = []
	for node in find_children("*", "SpawnComponent", true, false):
		components.append(node as SpawnComponent)
	return components


func _on_ant_spawned(ant: Node2D) -> void:
	_active_ants[ant] = true
	spawned_ants += 1


func _on_bucket_body_entered(body: Node2D) -> void:
	if not _is_running or not _active_ants.has(body):
		return
	captured_ants += 1
	_remove_ant(body)
	AudioUtils._play_sound_effect(self, load("res://Assets/Sounds/Effects/woosh_balde.mp3"))
	var particles = bucket.get_node("ExplodingParticles/CPUParticles2D")
	particles._explode()


func _remove_ant(ant: Node2D) -> void:
	_active_ants.erase(ant)
	if is_instance_valid(ant) and not ant.is_queued_for_deletion():
		ant.queue_free()


func _fit_background_to_viewport() -> void:
	var texture_size := background.texture.get_size()
	var viewport_size := get_viewport_rect().size
	var cover_scale := maxf(viewport_size.x / texture_size.x, viewport_size.y / texture_size.y)
	background.global_position = viewport_size * 0.5
	background.scale = Vector2.ONE * cover_scale


func _update_countdown() -> void:
	countdown_label.text = str(ceili(_remaining_seconds))


func _finish_level() -> void:
	_is_running = false
	for ant in _active_ants.keys():
		_remove_ant(ant as Node2D)
	_active_ants.clear()
	for spawn_component in _spawn_components:
		spawn_component.stop_spawning()
	GameSession.save_level_result("Ant invasion", captured_ants, spawned_ants)
	print("Ant invasion finished — captured: %d | spawned: %d" % [captured_ants, spawned_ants])
	get_tree().quit()
