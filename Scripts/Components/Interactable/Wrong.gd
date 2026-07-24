class_name Wrong extends InteractableBehavior

signal wrong

@export var wrong_sound: AudioStream

var _is_popping := false


func interaction_started(_mouse_position: Vector2, _button: MouseButton) -> void:
	if _is_popping:
		return
	var target := _target()
	if target == null:
		return

	_is_popping = true
	_pop(target)


func _pop(target: Node2D) -> void:
	var original_scale := target.scale
	var original_rotation := target.rotation
	
	var tween := target.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Fast wobble sequence
	tween.tween_property(target, "scale", original_scale * Vector2(1.15, 0.85), 0.04)
	tween.parallel().tween_property(target, "rotation", original_rotation + deg_to_rad(8.0), 0.04)
	
	tween.tween_property(target, "scale", original_scale * Vector2(0.85, 1.15), 0.04)
	tween.parallel().tween_property(target, "rotation", original_rotation - deg_to_rad(8.0), 0.04)
	
	tween.tween_property(target, "scale", original_scale * Vector2(1.1, 0.9), 0.03)
	tween.parallel().tween_property(target, "rotation", original_rotation + deg_to_rad(4.0), 0.03)
	
	tween.tween_property(target, "scale", original_scale, 0.04)
	tween.parallel().tween_property(target, "rotation", original_rotation, 0.04)
		
	await tween.finished

	_play_sound(target.global_position)

	_is_popping = false
	wrong.emit()


func _play_sound(global_pos: Vector2) -> void:
	if wrong_sound != null:
		var player := AudioStreamPlayer2D.new()
		player.stream = wrong_sound
		player.global_position = global_pos
		player.autoplay = true
		var tree := get_tree()
		if tree and tree.current_scene:
			tree.current_scene.add_child(player)
			player.finished.connect(player.queue_free)


func _target() -> Node2D:
	return get_parent().get_parent() as Node2D
