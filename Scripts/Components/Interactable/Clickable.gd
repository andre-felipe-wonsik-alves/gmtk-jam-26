class_name Clickable
extends InteractableBehavior

signal clicked


func interaction_started(
	_mouse_position: Vector2,
	_button: MouseButton
) -> void:
	clicked.emit()
