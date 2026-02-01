extends Node3D

const defaultRoomScene = preload("res://scenes/defaultRoom.tscn")
const roomSize = 10; 
var n := 4
var tutorialScene := preload("res://scenes/tutorial.tscn")
@onready var audio := AudioStreamPlayer.new()

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
var matrixs := [tutorialScene, matrix1, matrix2, matrix3, matrix4, matrix5]
@export var floor = 0
var node3d = Node3D
@onready var player = $Player

const wall = preload("res://scenes/decorations/doorBlocked.tscn")
const decoration1 = preload("res://scenes/decorations/decoration1.tscn")
const decoration2 = preload("res://scenes/decorations/decoration2.tscn")
const decoration3 = preload("res://scenes/decorations/decoration3.tscn")
const decoration4 = preload("res://scenes/decorations/decoration4.tscn")
const decoration5 = preload("res://scenes/decorations/decoration5.tscn")
var decorations = [decoration1, decoration2, decoration3, decoration4, decoration5]
@onready var finalRoom = $finalRoomDecoration
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	print_matrix()

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
					var habitacion = defaultRoomScene.instantiate()
					habitacion.position.x = x * roomSize
					habitacion.position.z = z * roomSize
					var chosenDecoration = randi() % decorations.size()
					if (!(chosenDecoration == decorations.size()) and (matrixs[floor][x][z] != 2) and !primero):
						var decoration = decorations[chosenDecoration].instantiate()
						habitacion.add_child(decoration)
					if (matrixs[floor][x][z] == 2):
						finalRoom.global_position = Vector3(x * roomSize, 0, z * roomSize)
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

func nextFloor() -> void:
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
	finalRoom.global_position = Vector3(0, 0, -70)
	floorMap.add_child(tutorial)
	if primero:
		primero = false
		player.position.x = 0
		player.position.z = 0
		player.position.y = 1
	add_child(floorMap)
	floor += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_walls(habitacion, x, z):
	if(matrixs[floor][x][z+1] == 0):
		var wall1 =wall.instantiate()
		wall1.rotation_degrees = Vector3(0, -90, 0)
		habitacion.add_child(wall1)
	if(matrixs[floor][x+1][z] == 0):
		habitacion.add_child(wall.instantiate())
	if(matrixs[floor][x][z-1] == 0):
		var wall1 =wall.instantiate()
		wall1.rotation_degrees = Vector3(0, 90, 0)
		habitacion.add_child(wall1)
	if(matrixs[floor][x-1][z] == 0):
		var wall1 =wall.instantiate()
		wall1.rotation_degrees = Vector3(0, 180, 0)
		habitacion.add_child(wall1)

func _on_area_3d_body_entered(body):
	print("Cofre recogido por: ", body.name)
	
	# Si es el último nivel (floor 5 = matrix5), mostrar victoria
	if floor >= len(matrixs):
		get_tree().change_scene_to_file("res://scenes/Victory.tscn")
	else:
		audio.stream = load("res://music/nextFloor.wav")
		audio.volume_db = -10
		add_child(audio)
		audio.play()
		nextFloor()
