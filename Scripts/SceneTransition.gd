extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# Garante que ao iniciar o jogo, o retângulo não bloqueie cliques nem fique visível
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.color.a = 0.0

# Função principal de transição
func change_scene(target_scene_path: String, anim_name: String = "fade_in") -> void:
	# Enquanto a tela escura está cobrindo tudo, podemos bloquear cliques acidentais
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 1. Toca a animação para cobrir a tela (ex: escurecer)
	anim.play(anim_name)
	await anim.animation_finished
	
	# 2. Enquanto a tela está totalmente coberta, troca a cena
	if ResourceLoader.exists(target_scene_path):
		get_tree().change_scene_to_file(target_scene_path)
	else:
		push_error("Cena não encontrada: " + target_scene_path)
		
	# 3. Toca a animação contrária (fade_out) para revelar a nova cena
	anim.play("fade_out")
	await anim.animation_finished
	
	# Libera os cliques do mouse novamente para os botões da nova cena
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
