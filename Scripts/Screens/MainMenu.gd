extends Control

@onready var play_button: Button = $PlayButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)

func _on_play_pressed() -> void:
	GameManager.start_game()
