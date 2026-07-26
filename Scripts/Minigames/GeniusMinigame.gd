class_name GeniusMinigame
extends MinigameBase

@export var sequence_length: int = 2
@export var turn_time_limit: float = 20.0
@export var secondary_time_limit: float = 5.0
@export var explosion_frame_duration: float = 0.25
@export var victory_display_duration: float = 2.0
@export var victory_slide_duration: float = 0.3
@export var victory_slide_distance: float = 145.0

@onready var sequence_generator: SequenceGeneratorComponent = $Components/SequenceGeneratorComponent
@onready var sequence_validator: SequenceValidatorComponent = $Components/SequenceValidatorComponent
@onready var timer_component: TimerComponent = $Components/TimerComponent
@onready var secondary_timer_component: TimerComponent = $Components/SecondaryTimerComponent
@onready var monitor_display: MonitorDisplayComponent = $UI/MonitorDisplayComponent

@onready var timer_label: Label = $UI/TimerLabel
@onready var buttons: Array[Node] = $UI/ButtonGrid.get_children()
@onready var explosion_animation: TextureRect = $UI/ExplosionAnimation
@onready var guy_animation: TextureRect = $UI/CoolGuy
@onready var thumbs_up_animation: TextureRect = $UI/CoolGuy/ThumbsUp

@onready var secondary_timer_label: Label = $UI/EmergencyPanel/SecondaryTimerLabel
@onready var secondary_button: TextureButton = $UI/EmergencyPanel/SecondaryButton

var current_sequence: Array[int] = []
var secondary_button_pressed: bool = false
var is_winning: bool = false
var is_losing: bool = false
var guy_target_position: Vector2 = Vector2.ZERO
var explosion_frames: Array[Texture2D] = [
	preload("res://Assets/Levels/Genius/boom1.png"),
	preload("res://Assets/Levels/Genius/boom2.png"),
	preload("res://Assets/Levels/Genius/boom3.png"),
	preload("res://Assets/Levels/Genius/boomfinal1.png"),
	preload("res://Assets/Levels/Genius/boomfinal2.png"),
	preload("res://Assets/Levels/Genius/boomfinal3.png")
]

var sounds: Array[AudioStreamMP3] = [
	preload("res://Assets/Sounds/Effects/genius_4.mp3"),
	preload("res://Assets/Sounds/Effects/genius_3.mp3"),
	preload("res://Assets/Sounds/Effects/genius_2.mp3"),
	preload("res://Assets/Sounds/Effects/genius_1.mp3"),
]

func _ready() -> void:
	super._ready()

	if explosion_animation:
		explosion_animation.visible = false

	if guy_animation:
		guy_target_position = guy_animation.position
		guy_animation.visible = false
	if thumbs_up_animation:
		thumbs_up_animation.visible = false

	# Conectar sinais dos componentes
	timer_component.time_updated.connect(_on_time_updated)
	timer_component.timeout.connect(_on_timer_timeout)

	secondary_timer_component.time_updated.connect(_on_secondary_time_updated)
	secondary_timer_component.timeout.connect(_on_secondary_timer_timeout)

	sequence_validator.sequence_completed.connect(_on_sequence_completed)
	sequence_validator.sequence_failed.connect(_on_sequence_failed)

	monitor_display.display_finished.connect(_on_display_finished)

	# Conectar botão do temporizador
	if secondary_button:
		secondary_button.pressed.connect(_on_secondary_button_pressed)
		secondary_button.disabled = true

	# Conectar botões coloridos
	for btn in buttons:
		if btn is ColorButtonComponent:
			btn.color_pressed.connect(_on_button_color_pressed)
			btn.disabled = true # Desativado durante o piscar do monitor

	start_genius_round()

func start_genius_round() -> void:
	secondary_button_pressed = false
	if secondary_timer_label:
		secondary_timer_label.text = "%.1fs" % secondary_time_limit
		secondary_timer_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))

	# 1. Gerar a sequência aleatória
	current_sequence = sequence_generator.generate_sequence(sequence_length)

	# 2. Desativar botões do jogador
	_set_buttons_enabled(false)

	# 3. Exibir a sequência no monitor e disparar o temporizador secundário
	monitor_display.play_sequence(current_sequence)

	if secondary_button:
		secondary_button.disabled = false
	secondary_timer_component.start_timer(secondary_time_limit)


func _on_display_finished() -> void:
	if is_winning or is_losing:
		return

	# 4. Sequência terminou: preparar validador, ativar botões e iniciar temporizador principal
	sequence_validator.set_target_sequence(current_sequence)
	_set_buttons_enabled(true)

	# Ativar temporizador principal
	timer_component.start_timer(turn_time_limit)

func _on_secondary_button_pressed() -> void:
	AudioUtils._play_sound_effect(self, load("res://Assets/Sounds/Effects/freesoundsxx-button-press-beep-269718.mp3"))
	
	if is_winning or is_losing:
		return

	secondary_button_pressed = true
	secondary_timer_component.stop_timer()

	# Para o timer atual e reinicia com o tempo limite cheio
	secondary_timer_component.stop_timer()
	secondary_timer_component.start_timer(secondary_time_limit)

func _on_button_color_pressed(color_id: int) -> void:
	if is_winning or is_losing:
		return

	# Feedback no monitor quando o jogador aperta um botão
	monitor_display.flash_color(color_id, 0.15)
	
	AudioUtils._play_sound_effect(self, sounds[color_id])

	# Envia a cor para validação
	sequence_validator.process_input(color_id)

func _on_sequence_completed() -> void:
	if is_winning or is_losing:
		return

	_play_victory_then_win()

func _play_victory_then_win() -> void:
	if is_winning or is_losing:
		return

	is_winning = true
	timer_component.stop_timer()
	secondary_timer_component.stop_timer()
	_set_buttons_enabled(false)
	if secondary_button:
		secondary_button.disabled = true

	if guy_animation:
		guy_animation.position = guy_target_position + Vector2(victory_slide_distance, 0.0)
		guy_animation.modulate.a = 0.0
		guy_animation.visible = true
	if thumbs_up_animation:
		thumbs_up_animation.visible = true

	if guy_animation:
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(guy_animation, "position", guy_target_position, victory_slide_duration)
		tween.parallel().tween_property(guy_animation, "modulate:a", 1.0, victory_slide_duration)
		await tween.finished

	await get_tree().create_timer(victory_display_duration, false).timeout
	# Garante que não chamará de novo
	var won_signal := won
	won.emit()

func _on_sequence_failed() -> void:
	_play_explosion_then_lose()

func _on_timer_timeout() -> void:
	_play_explosion_then_lose()

func _on_secondary_timer_timeout() -> void:
	# Temporizador secundário acabou antes do botão ser pressionado
	_play_explosion_then_lose()

func _play_explosion_then_lose() -> void:
	if is_winning or is_losing:
		return

	is_losing = true
	timer_component.stop_timer()
	secondary_timer_component.stop_timer()
	_set_buttons_enabled(false)
	if secondary_button:
		secondary_button.disabled = true

	if explosion_animation:
		explosion_animation.visible = true
		for frame in explosion_frames:
			explosion_animation.texture = frame
			await get_tree().create_timer(explosion_frame_duration, false).timeout

	lost.emit()

func _on_time_updated(time_remaining: float) -> void:
	if timer_label:
		timer_label.text = "%.1fs" % time_remaining

func _on_secondary_time_updated(time_remaining: float) -> void:
	if secondary_timer_label:	
		secondary_timer_label.text = "%.1fs" % time_remaining

func _set_buttons_enabled(enabled: bool) -> void:
	for btn in buttons:
		if btn is ColorButtonComponent:
			btn.disabled = not enabled
