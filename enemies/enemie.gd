extends CharacterBody3D

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

func _ready() -> void:
	# Asegura que la animación empieza siempre
	sprite.play()

func _physics_process(delta: float) -> void:
	# El enemigo no se mueve
	velocity = Vector3.ZERO

	# Si quieres que la gravedad NO le afecte, deja esto comentado
	move_and_slide()


# Llamado cuando el jugador dispara al enemigo
func take_damage(damage: int) -> void:
	print("¡Enemigo eliminado! Daño recibido: ", damage)
	queue_free()  # Elimina al enemigo de la escena
