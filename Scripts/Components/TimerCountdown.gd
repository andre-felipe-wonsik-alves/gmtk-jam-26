class_name TimerCountdown extends Control

signal countdown_finished

@export var tick_sound: AudioStream
@export var alarm_sound: AudioStream

@onready var label: Label = $BoxContainer/MarginContainer/HBoxContainer/Control/current
@onready var clock: AnimatedSprite2D = $BoxContainer/MarginContainer/HBoxContainer/Control/Clock

var _total_duration := 0.0
var _remaining_seconds := 0
var _is_running := false
var _timer: Timer = null
var _wobble_tween: Tween = null
var _original_scale := Vector2.ONE
var _original_clock_scale := Vector2.ONE


func _ready() -> void:
	if clock:
		_original_clock_scale = clock.scale
	_original_scale = scale


func start_countdown(duration_seconds: float) -> void:
	_total_duration = duration_seconds
	_remaining_seconds = ceili(duration_seconds)
	_update_label()
	_is_running = true

	if _timer == null:
		_timer = Timer.new()
		_timer.wait_time = 1.0
		_timer.one_shot = false
		_timer.timeout.connect(_on_tick)
		add_child(_timer)
	
	_timer.start()


func stop_countdown() -> void:
	_is_running = false
	if _timer:
		_timer.stop()


func get_remaining_seconds() -> int:
	return _remaining_seconds


func _on_tick() -> void:
	if not _is_running:
		return

	if _remaining_seconds > 0:
		_remaining_seconds -= 1
		_update_label()
		_play_tick_feedback()

	if _remaining_seconds == 0:
		_timer.stop()
		_on_timeout()


func _update_label() -> void:
	if label:
		label.text = str(_remaining_seconds)


func _play_tick_feedback() -> void:
	if tick_sound:
		AudioUtils._play_sound_effect(self, tick_sound)

	# Wobble animation on tick
	if _wobble_tween and _wobble_tween.is_running():
		_wobble_tween.kill()

	_wobble_tween = create_tween()
	_wobble_tween.set_trans(Tween.TRANS_SINE)
	_wobble_tween.set_ease(Tween.EASE_IN_OUT)

	var target_node: Node2D = clock if clock else self
	var base_scale := _original_clock_scale if clock else _original_scale
	var base_rot := target_node.rotation

	_wobble_tween.tween_property(target_node, "scale", base_scale * Vector2(1.18, 0.85), 0.05)
	_wobble_tween.parallel().tween_property(target_node, "rotation", base_rot + deg_to_rad(6.0), 0.05)

	_wobble_tween.tween_property(target_node, "scale", base_scale * Vector2(0.85, 1.18), 0.05)
	_wobble_tween.parallel().tween_property(target_node, "rotation", base_rot - deg_to_rad(6.0), 0.05)

	_wobble_tween.tween_property(target_node, "scale", base_scale, 0.05)
	_wobble_tween.parallel().tween_property(target_node, "rotation", base_rot, 0.05)


func _on_timeout() -> void:
	if alarm_sound:
		AudioUtils._play_sound_effect(self, alarm_sound)

	# Intense wobble animation when reaching 0 (loops continuously)
	if _wobble_tween and _wobble_tween.is_running():
		_wobble_tween.kill()

	_wobble_tween = create_tween().set_loops()
	_wobble_tween.set_trans(Tween.TRANS_SINE)
	_wobble_tween.set_ease(Tween.EASE_IN_OUT)

	var target_node: Node2D = clock if clock else self
	var base_scale := _original_clock_scale if clock else _original_scale

	_wobble_tween.tween_property(target_node, "scale", base_scale * Vector2(1.3, 0.7), 0.05)
	_wobble_tween.parallel().tween_property(target_node, "rotation", deg_to_rad(15.0), 0.05)

	_wobble_tween.tween_property(target_node, "scale", base_scale * Vector2(0.7, 1.3), 0.05)
	_wobble_tween.parallel().tween_property(target_node, "rotation", deg_to_rad(-15.0), 0.05)

	get_tree().create_timer(1.5).timeout.connect(func():
		countdown_finished.emit()
	)
