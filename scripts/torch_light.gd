extends OmniLight3D

# === CONFIGURACIÓN DEL PARPADEO ===
@export var base_energy: float = 3.0
@export var flicker_speed: float = 15.0
@export var flicker_amount: float = 0.8

# Variables internas
var time_offset: float = 0.0


func _ready() -> void:
	# Offset aleatorio para que cada antorcha sea diferente
	time_offset = randf() * 100.0


func _process(delta: float) -> void:
	# Crear efecto de parpadeo tipo fuego
	var time = Time.get_ticks_msec() * 0.001 + time_offset
	
	# Combinar varias ondas para efecto más orgánico
	var flicker = sin(time * flicker_speed) * 0.3
	flicker += sin(time * flicker_speed * 1.7) * 0.2
	flicker += sin(time * flicker_speed * 2.3) * 0.15
	
	# Añadir ruido aleatorio
	flicker += randf_range(-0.15, 0.15)
	
	# Aplicar a la energía de la luz
	light_energy = base_energy + (flicker * flicker_amount)
	
	# Pequeña variación de color (opcional - más amarillo/naranja)
	var color_shift = (flicker + 1.0) * 0.5  # Normalizar a 0-1
	light_color = Color(1.0, 0.5 + color_shift * 0.3, 0.1)
