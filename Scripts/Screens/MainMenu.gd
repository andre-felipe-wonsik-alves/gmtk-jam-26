extends Control

@onready var play_button: Button = $CenterContainer/Card/VBoxContainer/PlayButton
@onready var quit_button: Button = $CenterContainer/Card/VBoxContainer/QuitButton
@onready var card: Control = $CenterContainer/Card

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Espera um frame para o container calcular os tamanhos finais
	# antes de configurar o pivot dos botões (necessário para o scale
	# da animação de hover ficar centralizado)
	await get_tree().process_frame
	_add_button_juice(play_button)
	_add_button_juice(quit_button)
	_animate_card_in()

func _on_play_pressed() -> void:
	GameManager.start_game()

func _on_quit_pressed() -> void:
	get_tree().quit()

# Faz o card do menu entrar com um leve fade + mola
func _animate_card_in() -> void:
	card.pivot_offset = card.size / 2.0 # define o centro de rotação e escala exatamente no centro do card
	card.modulate.a = 0.0
	card.scale = Vector2(0.9, 0.9)

	var tween := create_tween().set_parallel(true) # cria uma animação temporária e faz com que as próximas rodem ao mesmo tempo
	tween.tween_property(card, "modulate:a", 1.0, 0.4) # card faz um fade in de 0.4 segundos
	tween.tween_property(card, "scale", Vector2.ONE, 0.4)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT) # efeito mola
	# .set_trans(Tween.TRANS_BACK): Define o tipo de transição física
	# O TRANS_BACK faz o objeto se esticar um pouco além do destino final antes de se ajustar
	# .set_ease(Tween.EASE_OUT): Define o ritmo da curva (Easing)
	# Com EASE_OUT, a animação começa rápida e vai desacelerando no final para suavizar a chegada

# Faz o botão cresces no hover e encolhe ao clicar
func _add_button_juice(button: Button) -> void:
	button.pivot_offset = button.size / 2.0 # define o centro de rotação e escala exatamente no centro do botão

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
