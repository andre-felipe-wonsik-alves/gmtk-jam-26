class_name InteractableComponent extends Node

## Attach this to a PhysicsBody2D and add InteractableBehavior children to define
## what happens while that body is being interacted with.
@export var interaction_button: MouseButton = MOUSE_BUTTON_LEFT

var _is_interacting := false


func start_interaction(mouse_position: Vector2, button: MouseButton) -> bool:
	if _is_interacting or button != interaction_button:
		return false
	_is_interacting = true
	for behavior in _behaviors():
		if behavior.enabled:
			behavior.interaction_started(mouse_position, button)
	return true


func update_interaction(mouse_position: Vector2) -> void:
	if not _is_interacting:
		return
	for behavior in _behaviors():
		if behavior.enabled:
			behavior.interaction_updated(mouse_position)


func stop_interaction(mouse_position: Vector2, button: MouseButton) -> void:
	if not _is_interacting or button != interaction_button:
		return
	for behavior in _behaviors():
		if behavior.enabled:
			behavior.interaction_ended(mouse_position, button)
	_is_interacting = false


func _behaviors() -> Array[InteractableBehavior]:
	var result: Array[InteractableBehavior] = []
	for child in get_children():
		if child is InteractableBehavior:
			result.append(child)
	return result
