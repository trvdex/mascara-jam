extends Node3D

# --- Ajustes exportados para modificar desde el Inspector ---
@export var spawn_radius: float = 10.0
@export var spawn_interval: float = 4.0
@export var enemy_scene: PackedScene  # asigna aquí tu escena de enemigo
@export var max_spawn_attempts: int = 10  # Intentos máximos para encontrar suelo
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
	var spawn_offset = Vector3(cos(angle) * distance, 0, sin(angle) * distance)
	
	# Posición de inicio del raycast (arriba del jugador + offset)
	var ray_origin = player.global_position + spawn_offset + Vector3(0, spawn_height, 0)
	var ray_end = ray_origin + Vector3(0, -spawn_height * 2, 0)  # Raycast hacia abajo
	
	# Hacer raycast para detectar suelo
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collision_mask = 2  # Capa del mundo/suelo (ajusta según tu configuración)
	
	var result = space_state.intersect_ray(query)
	
	if result:
		# Encontramos suelo, devolver la posición de impacto + pequeño offset
		return result.position + Vector3(0, 0.5, 0)
	
	# No hay suelo en esta posición
	return Vector3.ZERO


func _spawn_enemy_at(spawn_position: Vector3):
	var enemy_instance = enemy_scene.instantiate()
	
	# PRIMERO añadir al árbol, LUEGO establecer posición global
	get_tree().current_scene.add_child(enemy_instance)
	enemy_instance.global_position = spawn_position
