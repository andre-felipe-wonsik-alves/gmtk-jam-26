class_name Draggable extends InteractableBehavior

var _dragging := false
var _offset := Vector2.ZERO


func interaction_started(mouse_position: Vector2, _button: MouseButton) -> void:
	if _dragging:
		return
	var target := _target()
	if target == null:
		return
	_dragging = true
	
	_offset = target.global_position - mouse_position


func interaction_ended(_mouse_position: Vector2, _button: MouseButton) -> void:
	_dragging = false


func interaction_updated(mouse_position: Vector2) -> void:
	if not _dragging:
		return
	var target := _target()
	if target != null:
		target.global_position = mouse_position + _offset


func is_dragging() -> bool:
	return _dragging


func _target() -> Node2D:
	return get_parent().get_parent() as Node2D
