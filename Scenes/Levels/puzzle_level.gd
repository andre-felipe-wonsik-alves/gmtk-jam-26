extends Node2D

@onready var input_component: InputComponent = $InputComponent
@onready var interact_component: InteractComponent = $InteractComponent

@onready var blue_sensor: BlueSensor = $Interactables/BlueSensor
@onready var blue_gate: BlueGate = $Interactables/BlueGate

@onready var left_button: Clickable = $Interactables/RotationLever/LeftButton/InteractableComponent/Clickable

@onready var right_button: Clickable = $Interactables/RotationLever/RightButton/InteractableComponent/Clickable

@onready var yellow_platform: YellowPlatform = $Interactables/YellowPlatform

@onready var red_sensor_pair: RedSensorPair = $Interactables/RedSensorPair

@onready var red_gate: RedGate = $Interactables/RedGate

func _ready() -> void:
	# Sistema de interação com os objetos
	input_component.pointer_button_changed.connect(
		interact_component.process_pointer_button
	)

	input_component.pointer_moved.connect(
		interact_component.process_pointer_motion
	)

	# Sensor azul
	blue_sensor.activated.connect(blue_gate.open)
	blue_sensor.deactivated.connect(blue_gate.close)
	
	# Plataforma amarela
	left_button.clicked.connect(yellow_platform.rotate_left)
	right_button.clicked.connect(yellow_platform.rotate_right)

	# Par de sensores vermelhos
	red_sensor_pair.activated.connect(red_gate.open)
