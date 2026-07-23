class_name InteractableBehavior extends Node

## Base class for a behavior composed under an InteractableComponent.
## Override only the hooks a behavior needs.
@export var enabled := true


func interaction_started(_mouse_position: Vector2, _button: MouseButton) -> void:
	pass


func interaction_updated(_mouse_position: Vector2) -> void:
	pass


func interaction_ended(_mouse_position: Vector2, _button: MouseButton) -> void:
	pass
