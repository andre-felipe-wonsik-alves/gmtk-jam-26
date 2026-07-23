extends Node

# Sinais para avisar o restante do jogo sobre mudanças de estado
signal score_changed(new_score: int)
signal minigame_failed
signal minigame_passed

var current_level_index: int = 0
var score: int = 0

# Lista com os caminhos das cenas dos minigames
var minigames: Array[String] = [
	"res://Scenes/Minigames/minigame_teste1.tscn", # Exemplo de minigame 1
	#"res://minigames/minigame_green_click.tscn" # Exemplo de minigame 2
]

# Método para iniciar o minigame
func start_game() -> void:
	current_level_index = 0
	score = 0
	load_current_minigame_instruction()

# Carrega a tela de instrução antes de entrar na fase
func load_current_minigame_instruction() -> void:
	# Transição padrão suave (Fade)
	SceneTransition.change_scene("res://Scenes/Screens/transition_screen.tscn", "fade_in")

# Chama o minigame atual
func load_current_minigame() -> void:
	if current_level_index < minigames.size():
		# Transição padrão suave
		SceneTransition.change_scene(minigames[current_level_index], "fade_in")

# Chamado quando o jogador passa de fase
func pass_minigame() -> void:
	score += 1
	score_changed.emit(score)
	current_level_index += 1
	load_current_minigame_instruction()

# Chamado quando o jogador erra/morre
func fail_minigame() -> void:
	minigame_failed.emit()
	# Transição de morte/derrota
	SceneTransition.change_scene("res://Scenes/Screens/game_over_screen.tscn", "fade_in")
