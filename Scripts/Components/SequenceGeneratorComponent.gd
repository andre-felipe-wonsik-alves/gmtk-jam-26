class_name SequenceGeneratorComponent
extends Node

@export var default_sequence_length: int = 4
@export var total_colors: int = 4

func generate_sequence(length: int = -1) -> Array[int]:
	if length <= 0:
		length = default_sequence_length
		
	var sequence: Array[int] = []
	for i in range(length):
		sequence.append(randi() % total_colors)
	return sequence
