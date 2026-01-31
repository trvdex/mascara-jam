extends CharacterBody3D

@export var speed := 4.0

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D
@onready var player: Node3D = get_parent().get_node("Player")

@onready var enemyType:=randi_range(0,3)

func _ready() -> void:
	match enemyType:
		0:
			sprite.play("red")
		1:
			sprite.play("blue")
		2:
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
func take_damage(damage: int) -> void:
	print("¡Enemigo eliminado! Daño recibido: ", damage)
	queue_free()  # Elimina al enemigo de la escena
