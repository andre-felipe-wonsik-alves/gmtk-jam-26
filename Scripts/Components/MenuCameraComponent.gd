extends Camera2D

@export var max_offset: float = 20.0  # Max pixels the camera moves
@export var smooth_speed: float = 5.0 # How fast the camera catches up

var initial_position: Vector2

func _ready() -> void:
	initial_position = position

func _process(delta: float) -> void:
	var screen_center = get_viewport().get_visible_rect().size / 2.0
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Find offset from center, normalized and scaled
	var offset = (mouse_pos - screen_center) / screen_center
	var target_pos = initial_position + (offset * max_offset)
	
	# Smoothly move to target position
	position = position.lerp(target_pos, smooth_speed * delta)
