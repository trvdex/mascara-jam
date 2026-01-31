extends CharacterBody3D

# === MOVIMIENTO ===
@export var speed: float = 4.0

# === NODOS ===
@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D
@onready var player: Node3D = get_parent().get_node("Player")

# === TIPOS DE ENEMIGO ===
enum EnemyColor { RED, BLUE, GREEN }
@onready var enemyType: int = randi_range(0, 2)

func _ready() -> void:
	# Asignar animación según tipo
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

# --- DETECCIÓN DE COLISIÓN CON EL PLAYER ---
func _on_area_3d_body_entered(body: Node) -> void:
	print("Colisión con:", body.name)
	if body == player:
		hit_player()

func hit_player():
	if player:
		player.take_damage(1)
	die()

# --- RECIBIR DAÑO DEL JUGADOR ---
func take_damage(damage: int, ammo_type: int) -> void:
	if ammo_type == enemyType:
		print("¡Enemigo ", _get_color_name(), " eliminado! Daño recibido: ", damage)
		queue_free()  # Elimina al enemigo
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

func die():
	queue_free()
