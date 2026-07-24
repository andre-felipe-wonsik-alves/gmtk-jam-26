extends Node

# Sinais para avisar o restante do jogo sobre mudanças de estado
signal minigame_failed
signal minigame_passed

var current_level_index: int = 0
var array_index = 0;
var levels: Array

# Lista com os caminhos das cenas dos minigames
var minigames: Array[String] = [
	"res://Scenes/Minigames/ant.tscn",
	"res://Scenes/Minigames/genius_minigame.tscn",
	"res://Scenes/Minigames/city.tscn"
]

# Método para iniciar o minigame
func start_game() -> void:
	levels = generate_random_sequence(minigames.size())
	current_level_index = levels[array_index]
	array_index += 1
	load_current_minigame_instruction()

# Carrega a tela de instrução antes de entrar na fase
func load_current_minigame_instruction() -> void:
	# Transição padrão suave (Fade)
	SceneTransition.change_scene("res://Scenes/Screens/transition_screen.tscn", "fade_in")

# Chama o minigame atual
func load_current_minigame(show_countdown: bool = false) -> void:
	if current_level_index < minigames.size():
		# Transição padrão suave
		SceneTransition.change_scene(minigames[current_level_index], "fade_in", show_countdown)
			

# Chamado quando o jogador passa de fase
func pass_minigame() -> void:
	minigame_passed.emit()
	current_level_index = levels[array_index]
	array_index += 1
	load_current_minigame_instruction()

# Chamado quando o jogador erra/morre
func fail_minigame() -> void:
	minigame_failed.emit()
	# Transição de morte/derrota
	SceneTransition.change_scene("res://Scenes/Screens/game_over_screen.tscn", "fade_in")
	
# Criando um vetor para sortear os níveis
func generate_random_sequence(n: int) -> Array:
	var min_value = 0
	var max_value = n-1
	
	var pool: Array = []
	for i in range(min_value, max_value + 1):
		pool.append(i)
	
	pool.shuffle()

	# pega os primeiros n números
	return pool.slice(0, n)
