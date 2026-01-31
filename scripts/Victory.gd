extends Control

@onready var menu_button: Button = $VBoxContainer/MenuButton


func _ready() -> void:
	# Mostrar el cursor
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Conectar botón
	menu_button.pressed.connect(_on_menu_pressed)


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
