class_name BlueSensor
extends Area2D

signal activated
signal deactivated

@onready var visual: Polygon2D = $Polygon2D

var _players_inside: Array[Node2D] = []


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("players"):
		return

	if body in _players_inside:
		return

	_players_inside.append(body)

	if _players_inside.size() == 1:
		_activate()


func _on_body_exited(body: Node2D) -> void:
	if body not in _players_inside:
		return

	_players_inside.erase(body)

	if _players_inside.is_empty():
		_deactivate()


func _activate() -> void:
	visual.color = Color.GREEN
	activated.emit()


func _deactivate() -> void:
	visual.color = Color.WHITE
	deactivated.emit()
