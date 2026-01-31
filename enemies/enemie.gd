extends CharacterBody3D

# === MOVIMIENTO ===
@export var speed: float = 4.0
@export var avoidance_strength: float = 3.0  # Fuerza de evasión de obstáculos

# === NODOS ===
@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D
@onready var player: Node3D = null

# === TIPOS DE ENEMIGO ===
enum EnemyColor { RED, BLUE, GREEN }
@onready var enemyType: int = randi_range(0, 2)

# === DETECCIÓN DE OBSTÁCULOS ===
var ray_left: RayCast3D
var ray_right: RayCast3D
var ray_front: RayCast3D

# Variables para evitar quedarse atascado
var stuck_timer: float = 0.0
var last_position: Vector3 = Vector3.ZERO
var random_offset: Vector3 = Vector3.ZERO


func _ready() -> void:
	# Buscar player de forma segura
	await get_tree().process_frame
	player = get_tree().current_scene.get_node_or_null("Player")
	
	# Crear raycasts para detección de obstáculos
	_setup_raycasts()
	
	# Asignar animación según tipo
	match enemyType:
		EnemyColor.RED:
			sprite.play("red")
		EnemyColor.BLUE:
			sprite.play("blue")
		EnemyColor.GREEN:
			sprite.play("green")


func _setup_raycasts() -> void:
	# Raycast frontal
	ray_front = RayCast3D.new()
	ray_front.target_position = Vector3(0, 0, -1.5)
	ray_front.collision_mask = 2  # Capa del mundo
	add_child(ray_front)
	ray_front.enabled = true
	
	# Raycast izquierdo
	ray_left = RayCast3D.new()
	ray_left.target_position = Vector3(-1.0, 0, -1.0)
	ray_left.collision_mask = 2
	add_child(ray_left)
	ray_left.enabled = true
	
	# Raycast derecho
	ray_right = RayCast3D.new()
	ray_right.target_position = Vector3(1.0, 0, -1.0)
	ray_right.collision_mask = 2
	add_child(ray_right)
	ray_right.enabled = true


func _physics_process(delta: float) -> void:
	if not player:
		return

	# --- MIRAR AL PLAYER ---
	var look_pos := player.global_position
	look_pos.y = global_position.y
	look_at(look_pos, Vector3.UP)

	# --- DIRECCIÓN BASE HACIA EL PLAYER ---
	var direction := (player.global_position - global_position)
	direction.y = 0
	direction = direction.normalized()

	# --- EVASIÓN DE OBSTÁCULOS ---
	var avoidance := _get_avoidance_direction()
	
	# Combinar dirección hacia jugador + evasión
	var final_direction := (direction + avoidance).normalized()

	# --- DETECCIÓN DE ATASCAMIENTO ---
	stuck_timer += delta
	if stuck_timer > 0.5:
		stuck_timer = 0.0
		if global_position.distance_to(last_position) < 0.1:
			# Está atascado, añadir dirección aleatoria
			random_offset = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized() * 2.0
		else:
			random_offset = random_offset.lerp(Vector3.ZERO, 0.3)
		last_position = global_position
	
	# Aplicar offset anti-atasco
	final_direction = (final_direction + random_offset * 0.5).normalized()

	# --- APLICAR VELOCIDAD ---
	velocity.x = final_direction.x * speed
	velocity.z = final_direction.z * speed

	# --- GRAVEDAD ---
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
	
	# --- DESLIZAMIENTO EN PAREDES ---
	# Si hay colisión, intentar deslizarse
	if get_slide_collision_count() > 0:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var normal = collision.get_normal()
			# Calcular dirección de deslizamiento
			var slide_dir = direction - normal * direction.dot(normal)
			velocity.x = slide_dir.x * speed * 0.8
			velocity.z = slide_dir.z * speed * 0.8


func _get_avoidance_direction() -> Vector3:
	var avoidance := Vector3.ZERO
	
	# Si hay obstáculo enfrente
	if ray_front and ray_front.is_colliding():
		# Decidir hacia dónde girar basándose en los rayos laterales
		var left_clear := not ray_left.is_colliding() if ray_left else true
		var right_clear := not ray_right.is_colliding() if ray_right else true
		
		if left_clear and not right_clear:
			avoidance += transform.basis.x * -avoidance_strength  # Girar izquierda
		elif right_clear and not left_clear:
			avoidance += transform.basis.x * avoidance_strength  # Girar derecha
		elif left_clear and right_clear:
			# Ambos lados libres, elegir aleatoriamente
			avoidance += transform.basis.x * avoidance_strength * sign(randf() - 0.5)
		else:
			# Ambos bloqueados, retroceder un poco
			avoidance += transform.basis.z * avoidance_strength
	else:
		# Sin obstáculo frontal, evitar obstáculos laterales suavemente
		if ray_left and ray_left.is_colliding():
			avoidance += transform.basis.x * avoidance_strength * 0.5
		if ray_right and ray_right.is_colliding():
			avoidance += transform.basis.x * -avoidance_strength * 0.5
	
	return avoidance


# --- DETECCIÓN DE COLISIÓN CON EL PLAYER ---
func _on_area_3d_body_entered(body: Node) -> void:
	if body == player:
		hit_player()


func hit_player():
	if player and player.has_method("take_damage"):
		player.take_damage(1)
	die()


# --- RECIBIR DAÑO DEL JUGADOR ---
func take_damage(damage: int, ammo_type: int) -> void:
	if ammo_type == enemyType:
		print("¡Enemigo ", _get_color_name(), " eliminado! Daño recibido: ", damage)
		call_deferred("queue_free")
	else:
		print("¡Munición incorrecta! Necesitas munición ", _get_color_name(), " para este enemigo.")


func _get_color_name() -> String:
	match enemyType:
		EnemyColor.RED:
			return "red"
		EnemyColor.BLUE:
			return "blue"
		EnemyColor.GREEN:
			return "green"
	return "uknown"


func die():
	call_deferred("queue_free")
