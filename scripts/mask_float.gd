extends Node3D

# Velocidad de rotación (grados por segundo)
@export var rotation_speed: float = 45.0

# Efecto de levitación
@export var float_amplitude: float = 0.3  # Altura del movimiento
@export var float_speed: float = 2.0  # Velocidad del movimiento

var initial_y: float = 0.0
var time_elapsed: float = 0.0


func _ready() -> void:
	initial_y = position.y


func _process(delta: float) -> void:
	# Rotación constante en Y
	rotate_y(deg_to_rad(rotation_speed * delta))
	
	# Efecto de levitación (sube y baja suavemente)
	time_elapsed += delta
	position.y = initial_y + sin(time_elapsed * float_speed) * float_amplitude
