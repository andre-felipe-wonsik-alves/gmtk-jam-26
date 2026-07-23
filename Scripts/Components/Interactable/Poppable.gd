class_name Poppable extends InteractableBehavior

signal popped

@export var pop_sound: AudioStream
@export var pop_particles: PackedScene

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
	
	tween.tween_property(target, "scale", Vector2.ZERO, 0.04)
	
	await tween.finished

	_spawn_particles(target.global_position)
	_play_sound(target.global_position)

	popped.emit()
	target.queue_free()


func _spawn_particles(global_pos: Vector2) -> void:
	if pop_particles != null:
		var particle_instance := pop_particles.instantiate()
		if particle_instance is Node2D:
			particle_instance.global_position = global_pos
		var tree := get_tree()
		if tree and tree.current_scene:
			tree.current_scene.add_child(particle_instance)
	else:
		# Fallback dynamic particles if no custom scene particle is assigned
		var particles := CPUParticles2D.new()
		particles.global_position = global_pos
		particles.emitting = true
		particles.one_shot = true
		particles.explosiveness = 0.9
		particles.amount = 16
		particles.lifetime = 0.4
		particles.direction = Vector2.ZERO
		particles.spread = 180.0
		particles.gravity = Vector2(0, 98)
		particles.initial_velocity_min = 60.0
		particles.initial_velocity_max = 140.0
		particles.scale_amount_min = 2.0
		particles.scale_amount_max = 5.0
		particles.color = Color(1.0, 0.9, 0.4, 0.9)
		
		var tree := get_tree()
		if tree and tree.current_scene:
			tree.current_scene.add_child(particles)
			tree.create_timer(particles.lifetime + 0.1).timeout.connect(particles.queue_free)


func _play_sound(global_pos: Vector2) -> void:
	if pop_sound != null:
		var player := AudioStreamPlayer2D.new()
		player.stream = pop_sound
		player.global_position = global_pos
		player.autoplay = true
		var tree := get_tree()
		if tree and tree.current_scene:
			tree.current_scene.add_child(player)
			player.finished.connect(player.queue_free)


func _target() -> Node2D:
	return get_parent().get_parent() as Node2D
