extends Node3D

# --- Ajustes exportados para modificar desde el Inspector ---
@export var spawn_radius: float = 10.0
@export var spawn_interval: float = 2.0
@export var enemy_scene: PackedScene  # asigna aquí tu escena de enemigo
@export var max_spawn_attempts: int = 3  # Intentos máximos para encontrar suelo
@export var spawn_height: float = 5.0  # Altura desde donde lanzar el raycast
@onready var player := get_parent().get_node("Player")

func _ready():
	# Llamada periódica cada spawn_interval segundos
	start_spawn_timer()

func start_spawn_timer():
	var timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.one_shot = false
	timer.autostart = true
	timer.connect("timeout", Callable(self, "_on_spawn_timer_timeout"))
	add_child(timer)

func _on_spawn_timer_timeout():
	var main = get_tree().current_scene
	var floor = int(main.floor)
	if floor != 1:
		if not enemy_scene or not player:
			return

		# Intentar encontrar una posición válida con suelo
		for i in range(max_spawn_attempts):
			var spawn_pos = _try_get_valid_spawn_position()
			if spawn_pos != Vector3.ZERO:
				_spawn_enemy_at(spawn_pos)
				return
		
		# Si no encontramos posición válida después de todos los intentos, no spawnear
		print("No se encontró posición válida para spawn después de ", max_spawn_attempts, " intentos")


func _try_get_valid_spawn_position() -> Vector3:
	# Calcula posición aleatoria dentro del radio
	var angle = randf() * TAU
	var distance = spawn_radius + randf() * spawn_radius  # Entre 1x y 2x el radio
	var spawn_offset = Vector3(cos(angle) * distance, 1.5, sin(angle) * distance)
	
	# Posición de inicio del raycast (arriba del jugador + offset)
	var ray_origin = player.global_position + spawn_offset + Vector3(0, spawn_height, 0)
	var ray_end = ray_origin + Vector3(0, -spawn_height * 2, 0)  # Raycast hacia abajo
	
	# Hacer raycast para detectar suelo
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collision_mask = 2  # Capa del mundo/suelo
	
	var result = space_state.intersect_ray(query)
	
	if result:
		# Verificar que la superficie es suelo (normal apunta hacia arriba)
		var normal = result.normal
		if normal.dot(Vector3.UP) > 0.7:  # Solo superficies horizontales
			return result.position + Vector3(0, 1, 0)
	
	# No hay suelo válido en esta posición
	return Vector3.ZERO


func _spawn_enemy_at(spawn_position: Vector3):
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.position.y = 1.0
	enemy_instance.scale = Vector3(0.4, 0.4, 1	)
	# PRIMERO añadir al árbol, LUEGO establecer posición global
	get_tree().current_scene.add_child(enemy_instance)
	enemy_instance.global_position = spawn_position
