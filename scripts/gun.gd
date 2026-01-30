extends Node3D

@onready var animation: AnimationPlayer = $Animation
var can_shoot: bool = true


func _ready() -> void:
	animation.play("IDLE")
	# Conectar señal para saber cuando termina la animación
	animation.animation_finished.connect(_on_animation_finished)


func _input(event: InputEvent) -> void:
	# Solo disparar con click izquierdo y si podemos disparar
	if event.is_action_pressed("shoot") and can_shoot:
		shoot()


func shoot() -> void:
	can_shoot = false
	animation.play("Shoot")


func _on_animation_finished(anim_name: String) -> void:
	# Cuando termina la animación de disparo, volver a idle
	if anim_name == "Shoot":
		animation.play("IDLE")
		can_shoot = true
