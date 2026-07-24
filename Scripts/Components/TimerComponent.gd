class_name TimerComponent
extends Node

signal time_updated(time_remaining: float)
signal timeout

@export var duration: float = 15.0

var time_remaining: float = 0.0
var is_running: bool = false

func _process(delta: float) -> void:
	if not is_running:
		return
		
	time_remaining -= delta # -= delta para subtrair o tempo decorrido desde o último frame
	if time_remaining <= 0.0:
		time_remaining = 0.0
		is_running = false
		time_updated.emit(0.0)
		timeout.emit()
	else:
		time_updated.emit(time_remaining)

func start_timer(custom_duration: float = -1.0) -> void:
	time_remaining = custom_duration if custom_duration > 0.0 else duration
	is_running = true
	time_updated.emit(time_remaining)

func stop_timer() -> void:
	is_running = false
