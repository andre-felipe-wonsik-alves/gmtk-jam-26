class_name MinigameBase
extends Node2D

# Sinais próprios do minigame
signal won
signal lost

@export var time_limit: float = 5.0
var is_active: bool = true

func _ready() -> void:
	# Conecta os próprios sinais ao GameManager
	won.connect(_on_won)
	lost.connect(_on_lost)

func _on_won() -> void:
	if not is_active: return
	is_active = false
	GameManager.pass_minigame()

func _on_lost() -> void:
	if not is_active: return
	is_active = false
	GameManager.fail_minigame()
