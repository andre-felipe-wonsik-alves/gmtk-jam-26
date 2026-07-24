class_name YellowPlatform
extends Node2D


func rotate_left() -> void:
	print("ROTATE LEFT")
	rotation -= PI / 2.0


func rotate_right() -> void:
	print("ROTATE RIGHT")
	rotation += PI / 2.0
