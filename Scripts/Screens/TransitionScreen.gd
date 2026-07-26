extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var title: Label = $CenterContent/VBox/TitleRow/Label
@onready var hint: RichTextLabel = $CenterContent/VBox/HintCard/HintMargin/Hint
@onready var image: TextureRect = $CenterContent/VBox/ImageFrame/ImageMargin/Image
@onready var countdown: Label = $CenterContent/VBox/Countdown
@onready var timer: Timer = $Timer

# Títulos para cada minigame
var names: Array[String] = [
	"ANT HAVOC",
	"REMEMBER THE COLORS",
	"CITY SORTING"
]

# Instruções para cada minigame (pode ser mapeado pelo índice)
var instructions: Array[String] = [
	"Catch all the ants!\nHint: Beware of the frogs and anteaters.",
	"Remember the colors!",
	"Select all the red things!"
]

# Imagens de cada
var images: Array[String] = [
	"res://Assets/Levels/Menu/ants.png",
	"res://Assets/Levels/Menu/genius.png",
	"res://Assets/Levels/Menu/city.png"
]

func _ready() -> void:
	var index = GameManager.current_level_index
	if index < instructions.size():
		title.text = names[index]
		hint.text = instructions[index]
		image.texture = load(images[index])
	else:
		hint.text = "Get ready!"

	# Começa a progressbar cheia
	progress_bar.max_value = timer.wait_time
	progress_bar.value = timer.wait_time

	# Conectando o sinal de término do Timer via código
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _process(_delta: float) -> void:
	# Esvazia a barra conforme o tempo passa, dando feedback visual
	# de quanto falta para o minigame começar
	if not timer.is_stopped():
		progress_bar.value = timer.time_left
		countdown.text = "Starting in %d..." % ceili(timer.time_left)

func _on_timer_timeout() -> void:
	GameManager.load_current_minigame(true)
