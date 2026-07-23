class_name SequenceValidatorComponent
extends Node

signal step_correct(step_index: int)
signal sequence_completed
signal sequence_failed

var target_sequence: Array[int] = []
var current_step: int = 0
var is_accepting_input: bool = false

func set_target_sequence(sequence: Array[int]) -> void:
	target_sequence = sequence
	current_step = 0
	is_accepting_input = true

func process_input(color_id: int) -> void:
	if not is_accepting_input or target_sequence.is_empty():
		return

	if color_id == target_sequence[current_step]:
		step_correct.emit(current_step)
		current_step += 1
		
		if current_step >= target_sequence.size():
			is_accepting_input = false
			sequence_completed.emit() # Emite o sinal de sequência concluída
	else:
		is_accepting_input = false
		sequence_failed.emit() # Emite o sinal de sequência errada

func disable_input() -> void:
	is_accepting_input = false
