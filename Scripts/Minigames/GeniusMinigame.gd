class_name GeniusMinigame
extends MinigameBase

@export var sequence_length: int = 4
@export var turn_time_limit: float = 20.0
@export var secondary_time_limit: float = 7.0

@onready var sequence_generator: SequenceGeneratorComponent = $Components/SequenceGeneratorComponent
@onready var sequence_validator: SequenceValidatorComponent = $Components/SequenceValidatorComponent
@onready var timer_component: TimerComponent = $Components/TimerComponent
@onready var secondary_timer_component: TimerComponent = $Components/SecondaryTimerComponent
@onready var monitor_display: MonitorDisplayComponent = $UI/MonitorDisplayComponent

@onready var timer_label: Label = $UI/TimerLabel
@onready var buttons: Array[Node] = $UI/ButtonGrid.get_children()

@onready var secondary_timer_label: Label = $UI/EmergencyPanel/SecondaryTimerLabel
@onready var secondary_button: Button = $UI/EmergencyPanel/SecondaryButton
@onready var secondary_status_label: Label = $UI/EmergencyPanel/StatusLabel
@onready var secondary_button_color_rect: ColorRect = $UI/EmergencyPanel/SecondaryButton/ButtonColorRect
@onready var secondary_button_text: Label = $UI/EmergencyPanel/SecondaryButton/ButtonText

var current_sequence: Array[int] = []
var secondary_button_pressed: bool = false

func _ready() -> void:
	super._ready()
	
	# Conectar sinais dos componentes
	timer_component.time_updated.connect(_on_time_updated)
	timer_component.timeout.connect(_on_timer_timeout)
	
	secondary_timer_component.time_updated.connect(_on_secondary_time_updated)
	secondary_timer_component.timeout.connect(_on_secondary_timer_timeout)
	
	sequence_validator.sequence_completed.connect(_on_sequence_completed)
	sequence_validator.sequence_failed.connect(_on_sequence_failed)
	
	monitor_display.display_finished.connect(_on_display_finished)
	
	# Conectar botão secundário / de emergência
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
	if secondary_status_label:
		secondary_status_label.text = "STATUS: AGUARDANDO..."
		secondary_status_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	if secondary_timer_label:
		secondary_timer_label.text = "Emergência: %.1fs" % secondary_time_limit
		secondary_timer_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	if secondary_button_color_rect:
		secondary_button_color_rect.color = Color(0.5, 0.5, 0.5, 1)
	if secondary_button_text:
		secondary_button_text.text = "DESATIVAR ALARME"
		
	# 1. Gerar a sequência aleatória
	current_sequence = sequence_generator.generate_sequence(sequence_length)
	
	# 2. Desativar botões do jogador
	_set_buttons_enabled(false)
	
	# 3. Exibir a sequência no monitor e disparar o temporizador secundário
	monitor_display.play_sequence(current_sequence)
	
	if secondary_button:
		secondary_button.disabled = false
	if secondary_button_color_rect:
		secondary_button_color_rect.color = Color(0.85, 0.25, 0.25, 1)
	if secondary_status_label:
		secondary_status_label.text = "STATUS: ATIVO! APERTE!"
		secondary_status_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	secondary_timer_component.start_timer(secondary_time_limit)

func _on_display_finished() -> void:
	# 4. Sequência terminou: preparar validador, ativar botões e iniciar temporizador principal
	sequence_validator.set_target_sequence(current_sequence)
	_set_buttons_enabled(true)
	
	# Ativar temporizador principal
	timer_component.start_timer(turn_time_limit)

func _on_secondary_button_pressed() -> void:
	if secondary_button_pressed:
		return
	secondary_button_pressed = true
	secondary_timer_component.stop_timer()
	if secondary_button:
		secondary_button.disabled = true
	if secondary_button_color_rect:
		secondary_button_color_rect.color = Color(0.2, 0.7, 0.3, 1)
	if secondary_button_text:
		secondary_button_text.text = "ALARME DESATIVADO"
	if secondary_status_label:
		secondary_status_label.text = "STATUS: DESATIVADO! OK"
		secondary_status_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.3))
	if secondary_timer_label:
		secondary_timer_label.text = "Emergência Segura!"
		secondary_timer_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.3))

func _on_button_color_pressed(color_id: int) -> void:
	# Feedback no monitor quando o jogador aperta um botão
	monitor_display.flash_color(color_id, 0.15)
	
	# Envia a cor para validação
	sequence_validator.process_input(color_id)

func _on_sequence_completed() -> void:
	timer_component.stop_timer()
	secondary_timer_component.stop_timer()
	_set_buttons_enabled(false)
	if secondary_button:
		secondary_button.disabled = true
		
	# Se o jogador não desativou o alarme a tempo, ele perde!
	if not secondary_button_pressed:
		lost.emit()
	else:
		won.emit()

func _on_sequence_failed() -> void:
	timer_component.stop_timer()
	secondary_timer_component.stop_timer()
	_set_buttons_enabled(false)
	if secondary_button:
		secondary_button.disabled = true
	lost.emit()

func _on_timer_timeout() -> void:
	secondary_timer_component.stop_timer()
	_set_buttons_enabled(false)
	if secondary_button:
		secondary_button.disabled = true
	lost.emit()

func _on_secondary_timer_timeout() -> void:
	# Temporizador secundário acabou antes do botão ser pressionado
	timer_component.stop_timer()
	_set_buttons_enabled(false)
	if secondary_button:
		secondary_button.disabled = true
	lost.emit()

func _on_time_updated(time_remaining: float) -> void:
	if timer_label:
		timer_label.text = "Tempo Principal: %.1fs" % time_remaining

func _on_secondary_time_updated(time_remaining: float) -> void:
	if secondary_timer_label and not secondary_button_pressed:
		secondary_timer_label.text = "Emergência: %.1fs" % time_remaining

func _set_buttons_enabled(enabled: bool) -> void:
	for btn in buttons:
		if btn is ColorButtonComponent:
			btn.disabled = not enabled
