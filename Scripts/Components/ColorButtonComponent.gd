class_name ColorButtonComponent
extends TextureButton

signal color_pressed(color_id: int)

@export var color_id: int = 0

var _original_modulate: Color

func _ready() -> void:
	pressed.connect(_on_pressed)
	_original_modulate = modulate
	_generate_click_mask()

# Faz o botão piscar (clareia brevemente) por um curto período de tempo
func flash(duration: float = 0.3) -> void:
	modulate = _original_modulate * 2.0  # Clareia para indicar ativação
	await get_tree().create_timer(duration, false).timeout
	modulate = _original_modulate

# Quando o botão é pressionado, ele pisca e emite um sinal com o ID da cor correspondente
func _on_pressed() -> void:
	flash(0.15)
	color_pressed.emit(color_id)

# Gera um click mask a partir da textura para que apenas os pixels opacos sejam clicáveis
func _generate_click_mask() -> void:
	if texture_normal:
		var image: Image = texture_normal.get_image()
		if image:
			var mask := BitMap.new()
			mask.create_from_image_alpha(image, 0.1)
			texture_click_mask = mask
