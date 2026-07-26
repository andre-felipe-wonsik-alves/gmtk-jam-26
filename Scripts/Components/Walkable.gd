class_name WalkBobComponent extends Node

## Componente de composição que simula um "passo cartunesco":
## faz um Node2D (geralmente uma cena estática) subir e descer
## compassadamente, dando a impressão de uma caminhada.
##
## Uso: adicione este node como filho do node que representa o
## "corpo" visual (ex: um Sprite2D ou o Node2D raiz) e configure
## `target` caso não seja o pai direto.

signal bob_step(going_up: bool)

@export var target: Node2D

## Altura do "passo", em pixels. Quanto maior, mais alto o salto do bob.
@export_range(1.0, 200.0, 1.0) var bob_height := 12.0

## Velocidade do movimento, em pixels/segundo. Controla a duração de
## cada trecho (subida ou descida) com base na altura: duracao = altura / velocidade.
@export_range(1.0, 1000.0, 1.0) var bob_speed := 80.0

## Curva de suavização do movimento. TRANS_SINE fica mais orgânico,
## TRANS_QUAD/TRANS_CUBIC dão um ar mais "cartoon" (aceleração/freada).
@export var trans_type := Tween.TRANS_SINE
@export var ease_type := Tween.EASE_IN_OUT

@export var autostart := true

var _tween: Tween
var _base_position: Vector2
var _running := false


func _ready() -> void:
	if target == null and get_parent() is Node2D:
		target = get_parent() as Node2D

	if target == null:
		push_error("WalkBobComponent: nenhum target definido nem encontrado no pai.")
		return

	_base_position = target.position

	if autostart:
		start_bobbing()


func start_bobbing() -> void:
	if _running or target == null:
		return
	_running = true
	_base_position = target.position
	_run_cycle()


func stop_bobbing(reset_position := true) -> void:
	_running = false
	if _tween != null and _tween.is_valid():
		_tween.kill()
	if reset_position and target != null:
		target.position = _base_position


func set_bob_params(height: float, speed: float) -> void:
	bob_height = height
	bob_speed = speed


func _run_cycle() -> void:
	if not _running or target == null:
		return

	var duration: float = bob_height / maxf(bob_speed, 0.01)

	_tween = create_tween()
	_tween.set_trans(trans_type)
	_tween.set_ease(ease_type)

	# Sobe
	_tween.tween_property(target, "position:y", _base_position.y - bob_height, duration)
	_tween.tween_callback(func(): bob_step.emit(true))

	# Desce
	_tween.tween_property(target, "position:y", _base_position.y, duration)
	_tween.tween_callback(func(): bob_step.emit(false))

	# Ao terminar o ciclo, reinicia (loop manual, permite trocar
	# height/speed em runtime entre um ciclo e outro)
	_tween.finished.connect(_run_cycle)
