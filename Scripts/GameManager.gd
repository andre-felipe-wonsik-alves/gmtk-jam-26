extends Node

# Sinais para avisar o restante do jogo sobre mudanças de estado
signal minigame_failed
signal minigame_passed

var current_level_index: int = 0
var array_index = 0
var levels: Array
var _is_transitioning: bool = false

# Lista com os caminhos das cenas dos minigames
var minigames: Array[String] = [
	"res://Scenes/Minigames/ant_minigame.tscn",
	"res://Scenes/Minigames/genius_minigame.tscn",
	"res://Scenes/Minigames/city_minigame.tscn"
]

func _ready() -> void:
	pass


# Método para iniciar o minigame
func start_game() -> void:
	levels = generate_random_sequence(minigames.size())
	array_index = 0
	_is_transitioning = false
	current_level_index = levels[array_index]
	array_index += 1
	load_current_minigame_instruction()


# Carrega a tela de instrução antes de entrar na fase
func load_current_minigame_instruction() -> void:
	# NÃO resetar _is_transitioning aqui: ainda estamos no meio da transição
	# (a trava só deve liberar quando o próximo minigame de fato carregar,
	# em load_current_minigame()). Resetar aqui permitia que uma segunda
	# chamada de pass_minigame()/fail_minigame() no mesmo frame passasse
	# pelo guard, causando o "won" duplicado.
	SceneTransition.change_scene("res://Scenes/Screens/transition_screen.tscn", "fade_in")


# Chama o minigame atual
func load_current_minigame(show_countdown: bool = false) -> void:
	_is_transitioning = false
	if current_level_index < minigames.size():
		# Transição padrão suave
		SceneTransition.change_scene(minigames[current_level_index], "fade_in", show_countdown)


# Chamado quando o jogador passa de fase
func pass_minigame() -> void:
	# Se já estiver trocando de fase, ignora chamadas duplicadas
	if _is_transitioning:
		return
	_is_transitioning = true

	print("GameManager: Minigame passou!")
	minigame_passed.emit()
	
	if array_index >= levels.size():
		print("GameManager: Todos os níveis concluídos! Voltando ao menu principal.")
		SceneTransition.change_scene("res://Scenes/main_menu.tscn", "fade_in")
		return

	current_level_index = levels[array_index]
	array_index += 1
	load_current_minigame_instruction()


# Chamado quando o jogador erra/morre
func fail_minigame() -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	
	print("GameManager: Minigame falhou!")
	minigame_failed.emit()
	# Transição de morte/derrota
	SceneTransition.change_scene("res://Scenes/Screens/game_over_screen.tscn", "fade_in")


# Criando um vetor para sortear os níveis
func generate_random_sequence(n: int) -> Array:
	var min_value = 0
	var max_value = n - 1
	
	var pool: Array = []
	for i in range(min_value, max_value + 1):
		pool.append(i)
	
	pool.shuffle()

	# pega os primeiros n números
	return pool.slice(0, n)
