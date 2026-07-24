class_name RedGate
extends Node2D

@onready var visual: Polygon2D = $Polygon2D


func open() -> void:
	visual.color = Color.CHOCOLATE
