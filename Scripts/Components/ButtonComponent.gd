class_name ButtonComponent
extends TextureButton

var _original_modulate: Color

func _ready() -> void:
	pressed.connect(_on_pressed)
	_original_modulate = modulate

# Faz o botão piscar por um curto período de tempo
func flash(duration: float = 0.3) -> void:
	modulate = _original_modulate * 1.5
	await get_tree().create_timer(duration, false).timeout
	modulate = _original_modulate

# Quando o botão é pressionado, ele pisca
func _on_pressed() -> void:
	flash(0.15)
