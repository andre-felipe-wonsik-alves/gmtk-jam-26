extends Control

@onready var label: RichTextLabel = $CenterContainer/VBoxContainer/RichTextLabel
@onready var progress_bar: ProgressBar = $CenterContainer/VBoxContainer/ProgressBar
@onready var timer: Timer = $Timer

# Instruções para cada minigame (pode ser mapeado pelo índice)
var instructions: Array[String] = [
	"[center]Clique nos objetos [color=red]VERMELHOS![/color][/center]",
	"[center]Decore a sequência de cores![/center]",
]

func _ready() -> void:
	var index = GameManager.current_level_index
	if index < instructions.size():
		label.text = instructions[index]
	else:
		label.text = "[center]Prepare-se![/center]"

	# Começa a progressbar cheia
	progress_bar.max_value = timer.wait_time
	progress_bar.value = timer.wait_time

	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _process(_delta: float) -> void:
	# Esvazia a barra conforme o tempo passa, dando feedback visual
	# de quanto falta para o minigame começar
	if not timer.is_stopped():
		progress_bar.value = timer.time_left

func _on_timer_timeout() -> void:
	GameManager.load_current_minigame()
