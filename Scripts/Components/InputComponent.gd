class_name InputComponent extends Node

## Coordinates are emitted in world space, so this also works with a Camera2D.
signal mouse_clicked(position: Vector2, button: MouseButton)
signal pointer_button_changed(position: Vector2, button: MouseButton, pressed: bool)
signal pointer_moved(position: Vector2)

var mouse_position := Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = _to_world_position(event.position)
		pointer_moved.emit(mouse_position)
	elif event is InputEventMouseButton:
		mouse_position = _to_world_position(event.position)
		pointer_button_changed.emit(mouse_position, event.button_index, event.pressed)
		if event.pressed:
			mouse_clicked.emit(mouse_position, event.button_index)


func _to_world_position(viewport_position: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * viewport_position
