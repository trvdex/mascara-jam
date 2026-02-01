extends CanvasLayer

signal resume_game
signal go_to_menu

@onready var resume_button = $Panel/VBoxContainer/ResumeButton
@onready var menu_button = $Panel/VBoxContainer/MenuButton
@onready var panel = $Panel

func _ready() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func _input(event: InputEvent) -> void:
	# ESC también puede volver a la partida
	if panel.visible and event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		_on_resume_pressed()

func _on_resume_pressed() -> void:
	resume_game.emit()

func _on_menu_pressed() -> void:
	go_to_menu.emit()
