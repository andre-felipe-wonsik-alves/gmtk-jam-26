extends Node2D

@onready var image: Sprite2D = $CenterContainer/Sprite2D

signal countdown_finished

var countdown_images: Array = [
	"res://Assets/Levels/Menu/tres.png",
	"res://Assets/Levels/Menu/dois.png",
	"res://Assets/Levels/Menu/um.png",
	"res://Assets/Levels/Menu/go.png"
]
var current_index = 0

func _ready() -> void:
	image.texture = null
	image.modulate.a = 0.0
	image.position = get_viewport_rect().size / 2
	image.top_level = true
	start_countdown()

func start_countdown() -> void:
	current_index = 0
	show_next_number()
	
func show_next_number() -> void:
	if current_index >= countdown_images.size():
		countdown_finished.emit()
		queue_free()  # remove countdown scene when done
		return

	if current_index < countdown_images.size()-1:
		AudioUtils._play_sound_effect(self, load("res://Assets/Sounds/Effects/freesound_community-buzzer-of-car-wash-107990.mp3"))
	else: 
		AudioUtils._play_sound_effect(self, load("res://Assets/Sounds/Effects/bizin_editado.mp3"))

	image.texture = load(countdown_images[current_index])
	_animate_pop()
	current_index += 1

	await get_tree().create_timer(1.2).timeout
	show_next_number()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _animate_pop() -> void:
	image.scale = Vector2(0.5, 0.5)
	image.modulate.a = 0.0
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(image, "scale", Vector2(1.2, 1.2), 0.2).set_trans(Tween.TRANS_BACK)
	tween.tween_property(image, "modulate:a", 1.0, 0.15)
	tween.chain().tween_property(image, "scale", Vector2(1.0, 1.0), 0.1)
