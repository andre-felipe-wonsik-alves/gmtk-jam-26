extends Control

@onready var star_icon: TextureRect = $StarIcon
@onready var star_icon2: TextureRect = $StarIcon2

@onready var retry_button: Button = $CenterContainer/Card/VBoxContainer/RetryButton
@onready var menu_button: Button = $CenterContainer/Card/VBoxContainer/MenuButton
@onready var card: Control = $CenterContainer/Card

@onready var target_scale_1: Vector2 = star_icon.scale
@onready var target_scale_2: Vector2 = star_icon2.scale if star_icon2 else Vector2.ONE

func _ready() -> void:
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	
	await get_tree().process_frame
	_add_button_juice(retry_button)
	_add_button_juice(menu_button)
	_animate_card_in()
	
	animate_stars()

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

func animate_stars() -> void:
	if not star_icon:
		return

	# Posições Y originais
	var base_y1: float = star_icon.position.y
	var base_y2: float = star_icon2.position.y if star_icon2 else 0.0

	# 1. POP IN (Entrada ao mesmo tempo)
	star_icon.scale = Vector2.ZERO
	star_icon.rotation_degrees = -12.0 # Inclinada para a esquerda

	if star_icon2:
		star_icon2.scale = Vector2.ZERO
		star_icon2.rotation_degrees = 12.0 # Inclinada para a direita (oposta)

	var intro_tween = create_tween().set_parallel(true)
	intro_tween.tween_property(star_icon, "scale", target_scale_1, 0.55)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	intro_tween.tween_property(star_icon, "rotation_degrees", 0.0, 0.55)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	if star_icon2:
		intro_tween.tween_property(star_icon2, "scale", target_scale_2, 0.55)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		intro_tween.tween_property(star_icon2, "rotation_degrees", 0.0, 0.55)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await intro_tween.finished

	# 2. LOOP INFINITO (Cada estrela em seu próprio Tween)
	
	# Tween da Estrela da Esquerda (StarIcon)
	var tween1 = create_tween().set_loops().set_parallel(true)
	# Sobe e desce
	tween1.tween_property(star_icon, "position:y", base_y1 - 14.0, 1.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween1.chain().tween_property(star_icon, "position:y", base_y1, 1.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# Gira para a esquerda (-6.0) primeiro
	tween1.tween_property(star_icon, "rotation_degrees", -6.0, 1.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween1.chain().tween_property(star_icon, "rotation_degrees", 6.0, 1.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Tween da Estrela da Direita (StarIcon2)
	if star_icon2:
		var tween2 = create_tween().set_loops().set_parallel(true)
		# Sobe e desce em sintonia
		tween2.tween_property(star_icon2, "position:y", base_y2 - 14.0, 1.2)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween2.chain().tween_property(star_icon2, "position:y", base_y2, 1.2)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		# Gira para a direita (+6.0) primeiro (Sentido Oposto)
		tween2.tween_property(star_icon2, "rotation_degrees", 6.0, 1.2)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween2.chain().tween_property(star_icon2, "rotation_degrees", -6.0, 1.2)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
