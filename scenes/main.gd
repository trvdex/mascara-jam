extends Node3D

const defaultRoomScene = preload("res://scenes/defaultRoom.tscn")
const roomSize = 10; 
var n := 4
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
var matrixs := [matrix1, matrix2, matrix3, matrix4, matrix5]
var floor = 0
var node3d = Node3D
@onready var player = $Player

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_3d_body_entered(body):
	print("me ha tocado", body.name)
	nextFloor()
