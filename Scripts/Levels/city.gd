class_name CityLevel extends Node2D

signal score_changed(new_score: int)

var score: int = 0:
	set(value):
		score = value
		score_changed.emit(score)


func _ready() -> void:
	_setup_spawn_listeners()


func _setup_spawn_listeners() -> void:
	var spawn_pools := get_node_or_null("SpawnPools")
	if spawn_pools == null:
		return
		
	for marker in spawn_pools.get_children():
		var spawn_component := marker.get_node_or_null("SpawnComponent") as SpawnComponent
		if spawn_component != null:
			spawn_component.spawned.connect(_on_entity_spawned)


func _on_entity_spawned(instance: Node2D) -> void:
	var interactable := instance.get_node_or_null("InteractableComponent") as InteractableComponent
	if interactable == null:
		return
		
	for child in interactable.get_children():
		if child is Poppable:
			child.popped.connect(_on_correct_clicked)
		elif child is Wrong:
			child.wrong.connect(_on_wrong_clicked)


func _on_correct_clicked() -> void:
	score += 1
	print("Item correto clicado! Pontuação: ", score)


func _on_wrong_clicked() -> void:
	score -= 1
	print("Item incorreto clicado! Pontuação: ", score)
