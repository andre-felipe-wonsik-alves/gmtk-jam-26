extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var anim: AnimationPlayer = $AnimationPlayer

const COUNTDOWN_SCENE = preload("res://Scenes/Screens/StartCountdown.tscn")

func _ready() -> void:
	# Garante que ao iniciar o jogo, o retângulo não bloqueie cliques nem fique visível
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.color.a = 0.0

# Função principal de transição
func change_scene(target_scene_path: String, anim_name: String = "fade_in", show_countdown: bool = false) -> void:
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	anim.process_mode = Node.PROCESS_MODE_ALWAYS

	# 1. Cobre a tela
	anim.play(anim_name)
	await anim.animation_finished

	# 2. Troca a cena
	if ResourceLoader.exists(target_scene_path):
		get_tree().change_scene_to_file(target_scene_path)
	else:
		push_error("Cena não encontrada: " + target_scene_path)
		return
	await get_tree().process_frame

	# 3. Pausa a árvore ANTES do fade_out, pra nova cena ficar congelada
	get_tree().paused = true

	# 4. Fade out revela a cena (congelada) por trás
	anim.play("fade_out")
	await anim.animation_finished   # espera SÓ essa animação terminar

	# 5. Countdown roda por cima da cena congelada
	if show_countdown:
		var countdown = COUNTDOWN_SCENE.instantiate()
		countdown.process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().current_scene.add_child(countdown)
		await countdown.countdown_finished
		if is_instance_valid(countdown):
			get_tree().current_scene.remove_child(countdown)

	# 6. Despausa — a cena começa a rodar
	get_tree().paused = false
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
