extends Control

@onready var play_button: Button = $PlayButton
@onready var quit_button: Button = $QuitButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	AudioUtils._play_sound_effect(self, load("res://Assets/Sounds/Effects/creatorshome-select-003-337609.mp3"))
	GameManager.start_game()

func _on_quit_pressed() -> void:
	get_tree().quit()
