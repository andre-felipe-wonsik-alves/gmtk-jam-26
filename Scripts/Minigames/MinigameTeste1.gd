extends MinigameBase

@onready var button: Button = $Button
@onready var button2: Button = $Button2

func _ready() -> void:
	super._ready() # Garante a execução do _ready pai
	button.pressed.connect(_on_button_pressed)
	button2.pressed.connect(_on_button2_pressed)

func _on_button_pressed() -> void:
	# Notifica que venceu acionando o sinal herdado
	won.emit()
	
func _on_button2_pressed() -> void:
	# Notifica que perdeu acionando o sinal herdado
	lost.emit()
