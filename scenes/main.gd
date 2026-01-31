extends Node3D

const defaultRoomScene = preload("res://scenes/defaultRoom.tscn")
const roomSize = 10; 
var n := 4
var matrix := []
@onready var player = $Player

const decoration1 = preload("res://scenes/decorations/decoration1.tscn")
const decoration2 = preload("res://scenes/decorations/decoration2.tscn")
const decoration3 = preload("res://scenes/decorations/decoration3.tscn")
const decoration4 = preload("res://scenes/decorations/decoration4.tscn")
const decoration5 = preload("res://scenes/decorations/decoration5.tscn")
var decorations = [decoration1, decoration2, decoration3, decoration4, decoration5]
const finalRoom = preload("res://scenes/decorations/decorationFinal.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var habitacionesMaximas = int(round(n*n*0.7))
	randomize()
	for i in range(0, n+2):
		matrix.append([])
		for j in range(0, n+2):				
			matrix[i].append(0)
	matrix[1][1] = 1;
	var result1 = 0
	var result2 = 0
	var numeroHabitacionesACrear
	var posiblesHabitacionesACrear = 0
	var habitacionEnSiguienteFila = false
	for i in range(1, n+1):
		habitacionEnSiguienteFila = false
		for j in range(1, n+1):
			if habitacionesMaximas < 0:
				break
			result1 = 0
			result2 = 0
			if !(matrix[i][j] == 0):
				posiblesHabitacionesACrear = 2
				if !habitacionEnSiguienteFila:
					numeroHabitacionesACrear = 1
				if i == n+1:
					posiblesHabitacionesACrear -= 1
				if j == n+1:
					posiblesHabitacionesACrear -= 1
				result1 = int(randi_range(0, 3) > 0)
				result2 = int(randi_range(0, 3) > 0)
				if i == n+1:
					result1 = 0
				if j == n+1:
					result2 = 0
				if (result1 == 0 and result2 == 0) and numeroHabitacionesACrear == 1:
					if !(i == n+1):
						result1 = 1
					if !(j == n+1) and result1 == 0:
						result2 = 1
				if result1 == 1:
					habitacionesMaximas -= 1
				if result2 == 1:
					habitacionesMaximas -= 1
			else:
				result1 = 0
				result2 = 0
			matrix[i+1][j] = result1
			matrix[i][j+1] = result2
	print_matrix(matrix, n+2)

func print_matrix(matrix: Array, size: int) -> void:
	var primero = true
	for x in range(size):
		var linea := ""
		for z in range(size):
			linea += str(matrix[x][z]) + " "
			if matrix[x][z] == 1:
				var habitacion = defaultRoomScene.instantiate()
				habitacion.position.x = x * roomSize
				habitacion.position.z = z * roomSize
				var chosenDecoration = randi() % decorations.size()
				if !(chosenDecoration == decorations.size()):
					var decoration = decorations[chosenDecoration].instantiate()
					habitacion.add_child(decoration)
				add_child(habitacion)
				if primero:
					primero = false
					player.position.x = x * roomSize
					player.position.z = z * roomSize
					player.position.y = 1
		print(linea)





# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
