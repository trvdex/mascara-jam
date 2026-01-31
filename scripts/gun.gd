extends Node3D

# === TIPOS DE MUNICIÓN ===
enum AmmoType { RED, BLUE, GREEN }

# Colores para cada tipo de munición
const AMMO_COLORS := {
	AmmoType.RED: Color(1, 0.4, 0.4),
	AmmoType.BLUE: Color(0.4, 0.6, 1),
	AmmoType.GREEN: Color(0.4, 1, 0.5)
}

# === NODOS ===
@onready var animation: AnimationPlayer = $Animation
@onready var spriteHandR: AnimatedSprite2D = $CanvasLayer/Control/HandR
@onready var spriteMask: AnimatedSprite2D = $CanvasLayer/Control/Right/Mask
@onready var spriteHandL: AnimatedSprite2D = $CanvasLayer/Control/HandL
@onready var shoot_sound: AudioStreamPlayer = $ShootSound

# === ESTADO ===
var can_shoot: bool = true
var current_ammo: AmmoType = AmmoType.RED


func _ready() -> void:
	animation.play("IDLE")
	# Conectar señal para saber cuando termina la animación
	animation.animation_finished.connect(_on_animation_finished)
	# Aplicar color inicial
	_apply_ammo_color()


func _input(event: InputEvent) -> void:
	# Solo disparar con click izquierdo y si podemos disparar
	if event.is_action_pressed("shoot") and can_shoot:
		shoot()
	
	# Cambio de munición con teclas numéricas
	if event.is_action_pressed("ammo_red"):
		switch_ammo(AmmoType.RED)
	elif event.is_action_pressed("ammo_blue"):
		switch_ammo(AmmoType.BLUE)
	elif event.is_action_pressed("ammo_green"):
		switch_ammo(AmmoType.GREEN)
	
	# Cambio de munición con rueda del ratón
	if event.is_action_pressed("ammo_next"):
		next_ammo()
	elif event.is_action_pressed("ammo_prev"):
		prev_ammo()


func shoot() -> void:
	can_shoot = false
	animation.play("Shoot")
	shoot_sound.play()


func _on_animation_finished(anim_name: String) -> void:
	# Cuando termina la animación de disparo, volver a idle
	if anim_name == "Shoot":
		animation.play("IDLE")
		can_shoot = true


# === SISTEMA DE MUNICIÓN ===

func switch_ammo(ammo_type: AmmoType) -> void:
	if current_ammo != ammo_type:
		current_ammo = ammo_type
		_apply_ammo_color()
		print("Munición cambiada a: ", AmmoType.keys()[current_ammo])


func next_ammo() -> void:
	var next_type := (current_ammo + 1) % AmmoType.size()
	switch_ammo(next_type as AmmoType)


func prev_ammo() -> void:
	var prev_type := (current_ammo - 1 + AmmoType.size()) % AmmoType.size()
	switch_ammo(prev_type as AmmoType)


func get_current_ammo_type() -> AmmoType:
	return current_ammo
	
func _apply_ammo_color() -> void:
	if spriteMask:
		if current_ammo == AmmoType.BLUE:
			spriteMask.play("blue")
		elif current_ammo == AmmoType.GREEN:
			spriteMask.play("green")
		else:#red
			spriteMask.play("red")
			
func update_health_animation(hp: int) -> void:
	if hp == 5:
		spriteHandR.play("five")
	elif hp == 4:
		spriteHandR.play("four") 
	elif hp == 3:
		spriteHandR.play("three") 
	elif hp == 2:
		spriteHandR.play("two") 
	elif hp == 1:
		spriteHandR.play("one")
	else:
		pass
