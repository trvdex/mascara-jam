extends Node3D

# Carga diferida - se cargan cuando se necesitan
var defaultRoomScenes = null
const roomSize = 10; 
var n := 4
var tutorialScene: PackedScene = null
@onready var audio := AudioStreamPlayer.new()

@onready var gun : Node3D =  $Player/Gun

var matrix1 := [[0, 0, 0, 0, 0, 0],
				[0, 1, 1, 1, 1, 0],
				[0, 1, 0, 1, 0, 0],
				[0, 1, 0, 0, 2, 0],
				[0, 1, 1, 1, 1, 0],
				[0, 0, 0, 0, 0, 0]]
var matrix2 := [[0, 0, 0, 0, 0, 0],
				[0, 1, 1, 1, 1, 0],
				[0, 1, 0, 0, 0, 0],
				[0, 1, 1, 1, 1, 0],
				[0, 0, 0, 0, 2, 0],
				[0, 0, 0, 0, 0, 0]]
var matrix3 := [[0, 0, 0, 0, 0, 0],
				[0, 1, 1, 0, 1, 0],
				[0, 0, 1, 0, 1, 0],
				[0, 1, 1, 1, 1, 0],
				[0, 2, 0, 0, 0, 0],
				[0, 0, 0, 0, 0, 0]]
var matrix4 := [[0, 0, 0, 0, 0, 0],
				[0, 1, 1, 1, 1, 0],
				[0, 0, 0, 1, 1, 0],
				[0, 0, 0, 1, 0, 0],
				[0, 0, 2, 1, 0, 0],
				[0, 0, 0, 0, 0, 0]]
var matrix5 := [[0, 0, 0, 0, 0, 0],
				[0, 1, 1, 1, 1, 0],
				[0, 0, 0, 1, 0, 0],
				[0, 2, 1, 1, 1, 0],
				[0, 0, 0, 1, 0, 0],
				[0, 0, 0, 0, 0, 0]]
var matrixs := []  # Se inicializa en _ready
@export var floor = 0
var node3d = Node3D
@onready var player = $Player

# Carga diferida para decoraciones
var walls = null
var decorations: Array = []

# Máscaras 3D para cada nivel (carga diferida)
var masks: Array = []
var current_mask: Node3D = null

@onready var finalRoom = $finalRoomDecoration

func _ready() -> void:
	randomize()
	# Cargar recursos necesarios
	_load_resources()
	print_matrix()

func _load_resources() -> void:
	# Cargar escenas principales
	tutorialScene = load("res://scenes/tutorial.tscn")
	defaultRoomScenes = [null,
						load("res://scenes/rooms/defaultRoom1.tscn"),
						load("res://scenes/rooms/defaultRoom2.tscn"),
						load("res://scenes/rooms/defaultRoom3.tscn"),
						load("res://scenes/rooms/defaultRoom4.tscn"),
						load("res://scenes/rooms/defaultRoom5.tscn")]
	walls = [null,
			load("res://scenes/rooms/doorBlocked1.tscn"),
			load("res://scenes/rooms/doorBlocked2.tscn"),
			load("res://scenes/rooms/doorBlocked3.tscn"),
			load("res://scenes/rooms/doorBlocked4.tscn"),
			load("res://scenes/rooms/doorBlocked5.tscn")]
	floor = 0;
	# Cargar decoraciones
	decorations = [
		load("res://scenes/decorations/decoration1.tscn"),
		load("res://scenes/decorations/decoration2.tscn"),
		load("res://scenes/decorations/decoration3.tscn"),
		load("res://scenes/decorations/decoration4.tscn"),
		load("res://scenes/decorations/decoration5.tscn")
	]
	
	# Cargar máscaras
	masks = [
		load("res://scenes/decorations/mask_red.tscn"),
		load("res://scenes/decorations/mask_blue.tscn"),
		load("res://scenes/decorations/mask_green.tscn")
	]
	
	# Inicializar array de matrices
	matrixs = [tutorialScene, matrix1, matrix2, matrix3, matrix4, matrix5]

func print_matrix() -> void:
	var primero = true
	var floorMap = node3d.new()
	floorMap.name = "map"+str(floor)
	if(floor == 0):
		create_tutorial()
	else:
		for x in range(6):
			var linea := ""
			for z in range(6):
				linea += str(matrixs[floor][x][z]) + " "
				if matrixs[floor][x][z] >= 1:
					var habitacion = defaultRoomScenes[floor].instantiate()
					habitacion.position.x = x * roomSize
					habitacion.position.z = z * roomSize
					var chosenDecoration = randi() % decorations.size()
					if (!(chosenDecoration == decorations.size()) and (matrixs[floor][x][z] != 2) and !primero):
						var decoration = decorations[chosenDecoration].instantiate()
						habitacion.add_child(decoration)
					if (matrixs[floor][x][z] == 2):
						# Colocar la máscara correspondiente al nivel
						spawn_mask_for_floor(x * roomSize, z * roomSize)
					add_walls(habitacion, x, z)
					floorMap.add_child(habitacion)
					if primero:
						primero = false
						player.position.x = x * roomSize
						player.position.z = z * roomSize
						player.position.y = 1
			print(linea)
		add_child(floorMap)
		floor += 1

func spawn_mask_for_floor(pos_x: float, pos_z: float) -> void:
	# Eliminar máscara anterior si existe
	if current_mask:
		current_mask.queue_free()
	
	# Elegir máscara según el nivel (floor 1→red, 2→blue, 3→green, luego cicla)
	var mask_index = (floor) % 3  # 0=red, 1=blue, 2=green
	current_mask = masks[mask_index].instantiate()
	
	# PRIMERO añadir al árbol, LUEGO establecer posición global
	add_child(current_mask)
	current_mask.global_position = Vector3(pos_x, 1, pos_z)
	
	# Conectar la señal del Area3D de la máscara
	var area = current_mask.get_node("Area3D")
	if area:
		area.body_entered.connect(_on_mask_collected)

func _on_mask_collected(body) -> void:
	print("Máscara recogida por: ", body.name)
	
	# Si es el último nivel, mostrar victoria
	if floor >= len(matrixs):
		get_tree().change_scene_to_file("res://scenes/Victory.tscn")
	else:
		# Crear un nuevo AudioStreamPlayer para cada vez
		var next_floor_audio = AudioStreamPlayer.new()
		next_floor_audio.stream = load("res://music/nextFloor.wav")
		next_floor_audio.volume_db = -10
		add_child(next_floor_audio)
		next_floor_audio.play()
		next_floor_audio.finished.connect(next_floor_audio.queue_free)
		nextFloor()

func advanceMask() -> void:
	if floor == 1:#rojo
		gun.setRedMask()
	elif floor == 2:#rojo + azul
		gun.setBlueMask()
	elif floor == 3:#rojo + azul + verde
		gun.setGreenMask()
	elif floor == 4:#rojo + azul + verde
		pass
		
func nextFloor() -> void:
	advanceMask()
	clean_matrix()
	print_matrix()

func clean_matrix() -> void:
	var mapa = get_node("map"+str(floor-1))
	mapa.queue_free()

func create_tutorial() -> void:
	var primero = true
	var floorMap = node3d.new()
	floorMap.name = "map"+str(floor)
	var tutorial = tutorialScene.instantiate()
	
	# Ocultar y desactivar toda la decoración (cofre, cajas, barriles) en el tutorial
	finalRoom.visible = false
	# Mover lejos para evitar colisiones invisibles
	finalRoom.global_position = Vector3(1000, 1000, 1000)
	# Desactivar el Area3D del cofre
	var cofre = finalRoom.get_node("cofre2")
	if cofre:
		var area = cofre.get_node("Area3D")
		if area:
			area.monitoring = false
			area.monitorable = false
	
	# Colocar máscara roja en el tutorial
	spawn_mask_for_floor(0, -70)
	
	floorMap.add_child(tutorial)
	if primero:
		primero = false
		player.position.x = 0
		player.position.z = 0
		player.position.y = 1
	add_child(floorMap)
	floor += 1

func _process(delta: float) -> void:
	pass

func add_walls(habitacion, x, z):
	if(matrixs[floor][x][z+1] == 0):
		var wall1 = walls[floor].instantiate()
		wall1.rotation_degrees = Vector3(0, -90, 0)
		habitacion.add_child(wall1)
	if(matrixs[floor][x+1][z] == 0):
		habitacion.add_child( walls[floor].instantiate())
	if(matrixs[floor][x][z-1] == 0):
		var wall1 = walls[floor].instantiate()
		wall1.rotation_degrees = Vector3(0, 90, 0)
		habitacion.add_child(wall1)
	if(matrixs[floor][x-1][z] == 0):
		var wall1 = walls[floor].instantiate()
		wall1.rotation_degrees = Vector3(0, 180, 0)
		habitacion.add_child(wall1)

# Mantener compatibilidad con la conexión existente del cofre
func _on_area_3d_body_entered(body):
	_on_mask_collected(body)
