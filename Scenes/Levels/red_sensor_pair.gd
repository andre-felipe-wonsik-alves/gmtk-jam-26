class_name RedSensorPair
extends Node2D

signal activated

@onready var left_sensor: Area2D = $RedSensorLeft
@onready var right_sensor: Area2D = $RedSensorRight

@onready var left_visual: Polygon2D = $RedSensorLeft/Polygon2D
@onready var right_visual: Polygon2D = $RedSensorRight/Polygon2D

var _left_player: Node2D = null
var _right_player: Node2D = null

var _activated := false


func _ready() -> void:
	left_sensor.body_entered.connect(_on_left_sensor_body_entered)
	left_sensor.body_exited.connect(_on_left_sensor_body_exited)

	right_sensor.body_entered.connect(_on_right_sensor_body_entered)
	right_sensor.body_exited.connect(_on_right_sensor_body_exited)


func _on_left_sensor_body_entered(body: Node2D) -> void:
	if not body.is_in_group("players"):
		return

	if _left_player != null:
		return

	_left_player = body
	left_visual.color = Color.GREEN

	_check_activation()


func _on_left_sensor_body_exited(body: Node2D) -> void:
	if body != _left_player:
		return

	_left_player = null

	if not _activated:
		left_visual.color = Color.RED


func _on_right_sensor_body_entered(body: Node2D) -> void:
	if not body.is_in_group("players"):
		return

	if _right_player != null:
		return

	_right_player = body
	right_visual.color = Color.GREEN

	_check_activation()


func _on_right_sensor_body_exited(body: Node2D) -> void:
	if body != _right_player:
		return

	_right_player = null

	if not _activated:
		right_visual.color = Color.RED


func _check_activation() -> void:
	if _activated:
		return

	if _left_player == null:
		return

	if _right_player == null:
		return

	if _left_player == _right_player:
		return

	_activated = true

	activated.emit()
