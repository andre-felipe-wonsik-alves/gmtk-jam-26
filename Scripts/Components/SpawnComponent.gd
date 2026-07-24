class_name SpawnComponent extends Node

signal spawned(instance: Node2D)

@export var spawn_scene: PackedScene
## Optional array of scenes to pick randomly from on each spawn. If set and not empty, overrides spawn_scene.
@export var spawn_scenes: Array[PackedScene] = []
## Optional marker. If empty, the parent marker or first Marker2D child is used.
@export var spawn_marker: Marker2D
@export var path: Path2D
@export var path_follow: PathFollow2D
@export_range(0.1, 30.0, 0.1) var spawn_interval_seconds := 2.5
@export_range(1.0, 500.0, 1.0) var speed := 120
@export var reverse_path := false
@export var loop_path := false
@export var autostart := true

var _spawn_marker: Marker2D
var _spawn_elapsed := 0.0
var _running := false


class SpawnedInstance:
	var instance: Node2D
	var distance := 0.0

	func _init(new_instance: Node2D, initial_distance: float) -> void:
		instance = new_instance
		distance = initial_distance


var _moving_instances: Array[SpawnedInstance] = []


func _ready() -> void:
	_spawn_marker = spawn_marker
	if _spawn_marker == null and get_parent() is Marker2D:
		_spawn_marker = get_parent() as Marker2D
	if _spawn_marker == null:
		var markers := find_children("*", "Marker2D", true, false)
		if not markers.is_empty():
			_spawn_marker = markers[0] as Marker2D
	if autostart:
		call_deferred("start_spawning")


func _process(delta: float) -> void:
	if not _running:
		return
	_spawn_elapsed += delta
	while _spawn_elapsed >= spawn_interval_seconds:
		_spawn_elapsed -= spawn_interval_seconds
		_spawn()
	_advance_instances(delta)


func start_spawning() -> void:
	if _running:
		return
	_running = true
	_spawn()


func stop_spawning() -> void:
	_running = false


func _spawn() -> void:
	var scene_to_spawn := _get_scene_to_spawn()
	if scene_to_spawn == null or _spawn_marker == null:
		return
	var instance := scene_to_spawn.instantiate() as Node2D
	if instance == null:
		push_error("SpawnComponent spawn_scene must have a Node2D root.")
		return
	get_tree().current_scene.add_child(instance)
	instance.global_position = _spawn_marker.global_position
	spawned.emit(instance)
	if path != null and path.curve != null:
		var marker_on_path := path.to_local(_spawn_marker.global_position)
		var initial_distance := path.curve.get_closest_offset(marker_on_path)
		_moving_instances.append(SpawnedInstance.new(instance, initial_distance))


func _get_scene_to_spawn() -> PackedScene:
	if not spawn_scenes.is_empty():
		return spawn_scenes.pick_random()
	return spawn_scene


func _advance_instances(delta: float) -> void:
	if path == null or path.curve == null:
		return
	var path_length := path.curve.get_baked_length()
	path_follow.rotates = true
	
	if is_zero_approx(path_length):
		return
	for index in range(_moving_instances.size() - 1, -1, -1):
		var moving := _moving_instances[index]
		if not is_instance_valid(moving.instance) or moving.instance.is_queued_for_deletion():
			_moving_instances.remove_at(index)
			continue
		var draggable := moving.instance.get_node_or_null("InteractableComponent/Draggable") as Draggable
		if draggable != null and draggable.is_dragging():
			var shake_strength := 1.3  # pixels
			var shake_rotation := 0.15  # radians
			var jitter := Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_strength
			var global_jitter = jitter + moving.instance.global_position
			moving.instance.transform = Transform2D(shake_rotation*jitter.x, global_jitter)
			continue
		var direction := -1.0 if reverse_path else 1.0
		moving.distance += speed * delta * direction
		if loop_path:
			moving.distance = wrapf(moving.distance, 0.0, path_length)
		elif moving.distance < 0.0 or moving.distance > path_length:
			moving.instance.queue_free()
			_moving_instances.remove_at(index)
			continue
			
		var sample_dist = clamp(moving.distance, 0.0, path_length)
		var ahead = clamp(sample_dist - 1.0, 0.0, path_length)
		var behind = clamp(sample_dist + 1.0, 0.0, path_length)

		var tangent: Vector2 = path.curve.sample_baked(ahead) - path.curve.sample_baked(behind)
		moving.instance.transform = Transform2D(tangent.angle(), path.to_global(path.curve.sample_baked(sample_dist)))
