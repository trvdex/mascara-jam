extends CharacterBody3D

@export var speed := 4.0

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D
@onready var player: Node3D = get_parent().get_node("Player")

# Tipos de enemigo (debe coincidir con AmmoType en gun.gd)
enum EnemyColor { RED, BLUE, GREEN }

@onready var enemyType: int = randi_range(0, 2)

func _ready() -> void:
	match enemyType:
		EnemyColor.RED:
			sprite.play("red")
		EnemyColor.BLUE:
			sprite.play("blue")
		EnemyColor.GREEN:
			sprite.play("green")
	
func _physics_process(delta: float) -> void:
	if not player:
		return

	# --- MIRAR AL PLAYER ---
	var look_pos := player.global_position
	look_pos.y = global_position.y
	look_at(look_pos, Vector3.UP)

	# --- MOVERSE HACIA EL PLAYER ---
	var direction := (player.global_position - global_position)
	direction.y = 0
	direction = direction.normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# --- GRAVEDAD ---
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()


# Llamado cuando el jugador dispara al enemigo
func take_damage(damage: int, ammo_type: int) -> void:
	# Verificar si el color de la munición coincide con el color del enemigo
	if ammo_type == enemyType:
		print("¡Enemigo ", _get_color_name(), " eliminado! Daño recibido: ", damage)
		queue_free()  # Elimina al enemigo de la escena
	else:
		print("¡Munición incorrecta! Necesitas munición ", _get_color_name(), " para este enemigo.")


func _get_color_name() -> String:
	match enemyType:
		EnemyColor.RED:
			return "ROJA"
		EnemyColor.BLUE:
			return "AZUL"
		EnemyColor.GREEN:
			return "VERDE"
	return "DESCONOCIDO"
