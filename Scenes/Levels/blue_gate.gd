class_name BlueGate
extends StaticBody2D

@onready var visual: Polygon2D = $Polygon2D


func open() -> void:
	visual.color = Color.GREEN


func close() -> void:
	visual.color = Color.RED
