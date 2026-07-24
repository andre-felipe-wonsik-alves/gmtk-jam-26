class_name ButtonComponent
extends BaseButton

@export var normal_color: Color = Color.RED
@export var active_color: Color = Color(1.0, 0.4, 0.4)

@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	pressed.connect(_on_pressed)
	set_visual_active(false)

func set_visual_active(active: bool) -> void:
	if color_rect:
		color_rect.color = active_color if active else normal_color

# Faz o botão piscar por um curto período de tempo
func flash(duration: float = 0.3) -> void:
	set_visual_active(true)
	await get_tree().create_timer(duration).timeout
	set_visual_active(false)

# Quando o botão é pressionado, ele pisca e emite um sinal com o ID da cor correspondente
func _on_pressed() -> void:
	flash(0.15)
