extends Node2D

# Distancia desde el centro
var radius = 100
# Velocidad de rotación (radianes por segundo)
var speed = 1.0
# Ángulos iniciales de cada nodo
var angles = [0, 2 * PI / 3, 4 * PI / 3]

func _process(delta):
	# Para cada hijo del contenedor
	for i in range(get_child_count()):
		var child = get_child(i)
		# Actualiza el ángulo
		angles[i] += speed * delta
		# Calcula la nueva posición
		child.position = Vector2(
			radius * cos(angles[i]),
			radius * sin(angles[i])
		)
