extends Control

# Referencias a los nodos
@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var credits_button: Button = $VBoxContainer/CreditsButton
@onready var exit_button: Button = $VBoxContainer/ExitButton
@onready var credits_panel: Panel = $CreditsPanel
@onready var back_button: Button = $CreditsPanel/VBoxContainer/BackButton

# Selectores (hijo de cada botón)
@onready var play_selector: TextureRect = $VBoxContainer/PlayButton/Selector
@onready var credits_selector: TextureRect = $VBoxContainer/CreditsButton/Selector
@onready var exit_selector: TextureRect = $VBoxContainer/ExitButton/Selector


func _ready() -> void:
	# Mostrar el cursor en el menú
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Conectar señales de los botones
	play_button.pressed.connect(_on_play_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	# Conectar señales de hover para mostrar/ocultar selector
	play_button.mouse_entered.connect(_on_play_hover)
	play_button.mouse_exited.connect(_on_play_unhover)
	credits_button.mouse_entered.connect(_on_credits_hover)
	credits_button.mouse_exited.connect(_on_credits_unhover)
	exit_button.mouse_entered.connect(_on_exit_hover)
	exit_button.mouse_exited.connect(_on_exit_unhover)


# === HOVER EFFECTS ===
func _on_play_hover() -> void:
	play_selector.visible = true

func _on_play_unhover() -> void:
	play_selector.visible = false

func _on_credits_hover() -> void:
	credits_selector.visible = true

func _on_credits_unhover() -> void:
	credits_selector.visible = false

func _on_exit_hover() -> void:
	exit_selector.visible = true

func _on_exit_unhover() -> void:
	exit_selector.visible = false


# === BUTTON ACTIONS ===
func _on_play_pressed() -> void:
	# Cambiar a la escena principal del juego
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_credits_pressed() -> void:
	# Mostrar panel de créditos
	credits_panel.visible = true


func _on_exit_pressed() -> void:
	# Cerrar el juego
	get_tree().quit()


func _on_back_pressed() -> void:
	# Ocultar panel de créditos
	credits_panel.visible = false
