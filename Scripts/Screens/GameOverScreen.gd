extends Control

@onready var retry_button: Button = $RetryButton
@onready var menu_button: Button = $MenuButton

func _ready() -> void:
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func _on_retry_pressed() -> void:
	# Reinicia do minijogo atual onde ele errou
	GameManager.load_current_minigame_instruction()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
