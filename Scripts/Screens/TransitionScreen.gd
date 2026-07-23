extends Control

@onready var label: RichTextLabel = $RichTextLabel
@onready var timer: Timer = $Timer

# Instruções para cada minijogo (pode ser mapeado pelo índice)
var instructions: Array[String] = [
	"[center]Clique nos objetos [color=red]VERMELHOS![/color][/center]",
	"Clique nos objetos [color=green]VERDES![/color]"
]

func _ready() -> void:
	var index = GameManager.current_level_index
	if index < instructions.size():
		label.text = instructions[index]
	else:
		label.text = "Prepare-se!"
	
	# Conectando o sinal de término do Timer via código
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	GameManager.load_current_minigame()
