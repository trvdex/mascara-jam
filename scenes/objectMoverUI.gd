extends AnimatedSprite2D

@export var amplitud := 4.0    # píxeles que sube y baja (muy poco)
@export var velocidad := 1.5   # velocidad del movimiento

var tiempo := 0.0
var posicion_inicial : Vector2

func _ready():
	posicion_inicial = position

func _process(delta):
	tiempo += delta * velocidad
	position.y = posicion_inicial.y + sin(tiempo) * amplitud
