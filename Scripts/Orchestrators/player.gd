class_name Player extends CharacterBody2D

@onready var input_component: InputComponent = $InputComponent
@onready var interact_component: InteractComponent = $InteractComponent
@onready var model: MeshInstance2D = $Model

## The open-hand texture comes from Model.texture, configured in player.tscn.
@export var closed_hand_texture: Texture2D

var _open_hand_texture: Texture2D


func _ready() -> void:
	_open_hand_texture = model.texture
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	# The orchestrator wires input to interaction; neither component depends on Player.
	input_component.pointer_button_changed.connect(interact_component.process_pointer_button)
	input_component.pointer_moved.connect(interact_component.process_pointer_motion)
	input_component.pointer_button_changed.connect(_move_cursor_from_button)
	input_component.pointer_moved.connect(_move_cursor)
	interact_component.interaction_started.connect(_show_closed_hand)
	interact_component.interaction_ended.connect(_show_open_hand)


func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _move_cursor(mouse_position: Vector2) -> void:
	global_position = mouse_position


func _move_cursor_from_button(mouse_position: Vector2, _button: MouseButton, _pressed: bool) -> void:
	_move_cursor(mouse_position)


func _show_open_hand() -> void:
	model.texture = _open_hand_texture


func _show_closed_hand() -> void:
	AudioUtils._play_sound_effect(self, load("res://Assets/Sounds/Effects/dragon-studio-clean-whoosh-382726.mp3"))
	if closed_hand_texture != null:
		model.texture = closed_hand_texture
