extends Control

@onready var title: Label = $Label
@onready var hint: RichTextLabel = $RichTextLabel
@onready var image: Sprite2D = $Image
@onready var timer: Timer = $Timer

# Títulos para cada minigame 
var names: Array[String] = [
	"ANT HAVOC",
	"REMEMBER THE COLORS",
]

# Instruções para cada minigame (pode ser mapeado pelo índice)
var instructions: Array[String] = [
	"Catch all the ants!\nHint: Beware of the frogs and anteaters.",
	"Decore a sequência de cores!",
]

# Imagens de cada
var images: Array[String] = [
	"res://Assets/Levels/Menu/ants.png",
	"res://Assets/Levels/Menu/genius.png"
]

func _ready() -> void:
	var index = GameManager.current_level_index
	if index < instructions.size():
		title.text = names[index]
		title.add_theme_color_override("font_color", Color.BLACK)
		hint.text = instructions[index]
		hint.add_theme_color_override("font_color", Color.BLACK)
		image.texture = load(images[index])
	else:
		hint.text = "Prepare-se!"
	
	# Conectando o sinal de término do Timer via código
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	GameManager.load_current_minigame()
