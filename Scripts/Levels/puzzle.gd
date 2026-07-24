class_name PuzzleLevel
extends Node2D

@onready var input_component: InputComponent = $InputComponent
@onready var interact_component: InteractComponent = $InteractComponent


func _ready() -> void:
	input_component.pointer_button_changed.connect(
		interact_component.process_pointer_button
	)

	input_component.pointer_moved.connect(
		interact_component.process_pointer_motion
	)
