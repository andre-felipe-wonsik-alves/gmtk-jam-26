class_name InteractComponent extends Node

signal interaction_started
signal interaction_ended

var _active_interactable: InteractableComponent
var _active_button: MouseButton = MOUSE_BUTTON_NONE


func process_pointer_button(position: Vector2, button: MouseButton, pressed: bool) -> void:
	if pressed:
		_start_interaction(position, button)
	else:
		_stop_interaction(position, button)


func process_pointer_motion(position: Vector2) -> void:
	if is_instance_valid(_active_interactable):
		_active_interactable.update_interaction(position)


func _start_interaction(position: Vector2, button: MouseButton) -> void:
	if is_instance_valid(_active_interactable):
		return

	var query := PhysicsPointQueryParameters2D.new()
	query.position = position
	query.collide_with_areas = true
	query.collide_with_bodies = true

	for hit in get_viewport().world_2d.direct_space_state.intersect_point(query):
		var interactable := _find_interactable(hit.collider as Node)
		if interactable != null and interactable.start_interaction(position, button):
			_active_interactable = interactable
			_active_button = button
			interaction_started.emit()
			return


func _stop_interaction(position: Vector2, button: MouseButton) -> void:
	if not is_instance_valid(_active_interactable):
		var was_interacting := _active_button != MOUSE_BUTTON_NONE
		_active_interactable = null
		_active_button = MOUSE_BUTTON_NONE
		if was_interacting:
			interaction_ended.emit()
		return
	if button != _active_button:
		return
	_active_interactable.stop_interaction(position, button)
	_active_interactable = null
	_active_button = MOUSE_BUTTON_NONE
	interaction_ended.emit()


func _find_interactable(collider: Node) -> InteractableComponent:
	if collider == null:
		return null
	return collider.get_node_or_null("InteractableComponent") as InteractableComponent
