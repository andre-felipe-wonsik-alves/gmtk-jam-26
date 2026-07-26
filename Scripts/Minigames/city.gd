class_name CityLevel
extends MinigameBase

signal score_changed(new_score: int)

@export_range(1, 100, 1) var score_required_to_win := 10
@export_range(1.0, 120.0, 0.5) var level_duration_seconds := 20.0
@export var lose_on_wrong_click := false

var score: int = 0:
	set(value):
		score = value
		score_changed.emit(score)

var _remaining_seconds := 0.0
var _is_running := false
var _spawn_components: Array[SpawnComponent] = []


func _ready() -> void:
	super._ready()
	_setup_spawn_listeners()
	_remaining_seconds = level_duration_seconds
	_is_running = true
	print("--- Iniciando CityLevel --- Meta para vencer: ", score_required_to_win)


func _process(delta: float) -> void:
	if not _is_running:
		return

	_remaining_seconds = maxf(_remaining_seconds - delta, 0.0)
	
	# Quando o tempo acaba:
	if is_zero_approx(_remaining_seconds):
		print("Tempo esgotado! Pontuação final: ", score, "/", score_required_to_win)
		if score >= score_required_to_win:
			_finish_level(true)
		else:
			_finish_level(false)


func _setup_spawn_listeners() -> void:
	var spawn_pools := get_node_or_null("SpawnPools")
	if spawn_pools == null:
		return

	for marker in spawn_pools.get_children():
		var spawn_component := marker.get_node_or_null("SpawnComponent") as SpawnComponent
		if spawn_component != null:
			_spawn_components.append(spawn_component)
			spawn_component.spawned.connect(_on_entity_spawned)


func _on_entity_spawned(instance: Node2D) -> void:
	if not _is_running:
		return

	var interactable := instance.get_node_or_null("InteractableComponent") as InteractableComponent
	if interactable == null:
		return

	for child in interactable.get_children():
		if child is Poppable:
			child.popped.connect(_on_correct_clicked)
		elif child is Wrong:
			child.wrong.connect(_on_wrong_clicked)


func _on_correct_clicked() -> void:
	if not _is_running:
		return

	score += 1
	print("Item correto clicado! Pontuação atual: ", score, "/", score_required_to_win)
	
	# Se atingir ou ultrapassar a meta, VENCE NA HORA!
	if score >= score_required_to_win:
		print("Meta atingida! Emitindo vitória...")
		_finish_level(true)


func _on_wrong_clicked() -> void:
	if not _is_running:
		return

	score = max(0, score - 1)
	print("Item errado clicado! Pontuação reduzida para: ", score)


func _finish_level(did_win: bool) -> void:
	if not _is_running:
		return

	_is_running = false
	_stop_spawning()
	if did_win:
		print("Nível CONCLUÍDO (won emitido)")
		won.emit()
	else:
		print("Nível DERROTADO (lost emitido)")
		lost.emit()


func _stop_spawning() -> void:
	for spawn_component in _spawn_components:
		spawn_component.stop_spawning()
