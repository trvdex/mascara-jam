extends Node3D

# --- Ajustes exportados para modificar desde el Inspector ---
@export var spawn_radius: float = 10.0
@export var spawn_interval: float = 4.0
@export var enemy_scene: PackedScene  # asigna aquí tu escena de enemigo

@onready var player := get_parent().get_node("Player")  # ajusta según tu jerarquía

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

	# Calcula posición aleatoria dentro del radio
	var angle = randf() * TAU
	var distance = (1 + randi()%2)* spawn_radius
	var spawn_offset = Vector3(cos(angle) * distance, 0, sin(angle) * distance)

	# Posición final sobre el terreno
	var spawn_position = player.global_position + spawn_offset
	var enemy_instance = enemy_scene.instantiate()

	# PRIMERO añadir al árbol, LUEGO establecer posición global
	get_tree().current_scene.add_child(enemy_instance)
	enemy_instance.global_position = spawn_position
