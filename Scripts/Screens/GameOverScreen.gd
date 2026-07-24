extends Control

@onready var retry_button: Button = $CenterContainer/Card/VBoxContainer/RetryButton
@onready var menu_button: Button = $CenterContainer/Card/VBoxContainer/MenuButton
@onready var card: Control = $CenterContainer/Card

func _ready() -> void:
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

	await get_tree().process_frame
	_add_button_juice(retry_button)
	_add_button_juice(menu_button)
	_animate_card_in()

func _on_retry_pressed() -> void:
	# Reinicia do minigame atual onde ele errou
	GameManager.load_current_minigame_instruction()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

# Card desce levemente enquanto aparece (fade + slide)
func _animate_card_in() -> void:
	card.pivot_offset = card.size / 2.0
	var final_y := card.position.y # posição y onde o card deve estar
	card.modulate.a = 0.0
	card.position.y = final_y - 30 # coloca o card 30 pixels acima da posição original

	var tween := create_tween().set_parallel(true)
	tween.tween_property(card, "modulate:a", 1.0, 0.35)
	tween.tween_property(card, "position:y", final_y, 0.35)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT) # efeito slide

func _add_button_juice(button: Button) -> void:
	button.pivot_offset = button.size / 2.0

	button.mouse_entered.connect(func():
		create_tween().tween_property(button, "scale", Vector2(1.06, 1.06), 0.12)
	)
	button.mouse_exited.connect(func():
		create_tween().tween_property(button, "scale", Vector2.ONE, 0.12)
	)
	button.button_down.connect(func():
		create_tween().tween_property(button, "scale", Vector2(0.95, 0.95), 0.08)
	)
	button.button_up.connect(func():
		create_tween().tween_property(button, "scale", Vector2(1.06, 1.06), 0.08)
	)
