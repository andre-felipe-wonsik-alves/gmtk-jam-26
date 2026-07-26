class_name MonitorDisplayComponent
extends Control

signal display_started
signal display_finished

@export var flash_duration: float = 0.5  # Duração do flash em segundos
@export var pause_duration: float = 0.4 # Duração da pausa entre flashes em segundos 

@onready var screen_rect: ColorRect = $ScreenRect
@onready var status_label: Label = $StatusLabel

# Cores correspondentes aos IDs: 0 = Azul, 1 = Vermelho, 2 = Amarelo, 3 = Verde
const COLOR_MAP: Array[Color] = [
	Color(0.2, 0.4, 1.0), # 0: Azul
	Color(1.0, 0.2, 0.2), # 1: Vermelho
	Color(1.0, 0.9, 0.1), # 2: Amarelo
	Color(0.2, 0.9, 0.2)  # 3: Verde
]

const OFF_COLOR: Color = Color(0.1, 0.1, 0.15) # Cor de fundo quando a tela está desligada

func _ready() -> void:
	set_screen_color(OFF_COLOR)
	if status_label:
		status_label.text = "Waiting..."

func play_sequence(sequence: Array[int]) -> void:
	display_started.emit()
	if status_label:
		status_label.text = "Pay attention!"
		
	for color_id in sequence:
		await get_tree().create_timer(pause_duration, false).timeout # Pausa antes de cada flash
		if color_id >= 0 and color_id < COLOR_MAP.size():
			set_screen_color(COLOR_MAP[color_id])
			await get_tree().create_timer(flash_duration, false).timeout # Duração do flash
			set_screen_color(OFF_COLOR)
			
	await get_tree().create_timer(pause_duration, false).timeout # Pausa final antes de indicar que a exibição terminou
	if status_label:
		status_label.text = "Your turn!"
	display_finished.emit()

func set_screen_color(color: Color) -> void:
	if screen_rect:
		screen_rect.color = color

# Função para piscar uma cor específica por um curto período de tempo
func flash_color(color_id: int, duration: float = 0.2) -> void:
	if color_id >= 0 and color_id < COLOR_MAP.size():
		set_screen_color(COLOR_MAP[color_id])
		await get_tree().create_timer(duration, false).timeout # Duração do flash
		set_screen_color(OFF_COLOR)
