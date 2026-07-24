class_name FrogBehavior extends Node

@export var hop_speed := 160.0
@export var attack_distance := 120.0
@export var idle_duration := 0.8
@export var attack_duration := 0.4
@export var tongue_color := Color(0.98, 0.4, 0.65, 1.0)
@export var tongue_width := 6.0

var _target_ant: Node2D = null
var _is_acting := false
var _line: Line2D = null
var _sprite: AnimatedSprite2D = null


func _ready() -> void:
	call_deferred("_setup")


func _setup() -> void:
	var parent := _parent_body()
	if parent:
		_sprite = parent.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	
	_line = Line2D.new()
	_line.width = tongue_width
	_line.default_color = tongue_color
	_line.z_index = -1
	_line.visible = false
	
	var tree := get_tree()
	if tree and tree.current_scene:
		tree.current_scene.add_child(_line)


func _exit_tree() -> void:
	if is_instance_valid(_line):
		_line.queue_free()


func _process(_delta: float) -> void:
	if _is_acting:
		return
	var parent := _parent_body()
	if parent == null or parent.is_queued_for_deletion():
		return

	# Target selection or validation
	if not is_instance_valid(_target_ant) or _target_ant.is_queued_for_deletion():
		_target_ant = _find_random_ant()

	if _target_ant == null:
		_set_animation("idle")
		return

	# Decide action based on distance
	var dist := parent.global_position.distance_to(_target_ant.global_position)
	if dist <= attack_distance:
		_attack_target()
	else:
		_hop_towards_target()


func _hop_towards_target() -> void:
	_is_acting = true
	var parent := _parent_body()
	if parent == null:
		return

	_set_animation("idle")
	await get_tree().create_timer(idle_duration).timeout
	
	if not is_instance_valid(parent) or parent.is_queued_for_deletion():
		return

	if not is_instance_valid(_target_ant) or _target_ant.is_queued_for_deletion():
		_is_acting = false
		return

	_set_animation("jump")
	
	var start_pos := parent.global_position
	var target_pos := _target_ant.global_position
	var dir := (target_pos - start_pos).normalized()
	
	parent.rotation = dir.angle() + (PI * 0.5)
	
	# Hop step distance
	var step_dist := minf(100.0, start_pos.distance_to(target_pos) - (attack_distance * 0.5))
	step_dist = maxf(step_dist, 30.0)
	var end_pos := start_pos + dir * step_dist
	var duration := step_dist / hop_speed

	var tween := parent.create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(parent, "global_position", end_pos, duration)

	await tween.finished
	_is_acting = false


func _attack_target() -> void:
	_is_acting = true
	var parent := _parent_body()
	if parent == null:
		return

	if not is_instance_valid(_target_ant) or _target_ant.is_queued_for_deletion():
		_is_acting = false
		return

	# Face ant
	var dir := (_target_ant.global_position - parent.global_position).normalized()
	parent.rotation = dir.angle() + (PI * 0.5)

	_set_animation("attack")

	# Draw tongue line from frog mouth (frog position) to ant
	if is_instance_valid(_line):
		_line.clear_points()
		_line.add_point(parent.global_position)
		_line.add_point(_target_ant.global_position)
		_line.visible = true

	await get_tree().create_timer(attack_duration * 0.5).timeout

	if is_instance_valid(_target_ant) and not _target_ant.is_queued_for_deletion():
		_target_ant.queue_free()

	await get_tree().create_timer(attack_duration * 0.5).timeout

	if is_instance_valid(_line):
		_line.visible = false

	_set_animation("idle")
	_target_ant = null
	_is_acting = false


func _set_animation(anim_name: StringName) -> void:
	if _sprite and _sprite.sprite_frames and _sprite.sprite_frames.has_animation(anim_name):
		_sprite.play(anim_name)


func _find_random_ant() -> Node2D:
	var tree := get_tree()
	if tree == null:
		return null
	var candidates: Array[Node2D] = []
	for node in tree.get_nodes_in_group("ants"):
		if is_instance_valid(node) and not node.is_queued_for_deletion():
			candidates.append(node as Node2D)
	if candidates.is_empty():
		return null
	return candidates.pick_random()


func _parent_body() -> Node2D:
	return get_parent() as Node2D
