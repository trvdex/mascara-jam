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
@onready var spriteHandR: AnimatedSprite2D = $CanvasLayer/Control/HandR
@onready var spriteMask: AnimatedSprite2D = $CanvasLayer/Control/Right/Mask
@onready var spriteHandL: AnimatedSprite2D = $CanvasLayer/Control/HandL

@onready var spriteRedRing: Sprite2D = $CanvasLayer/Control/HandR/RedRing
@onready var spriteBlueRing: Sprite2D = $CanvasLayer/Control/HandR/BlueRing
@onready var spriteGreenRing: Sprite2D = $CanvasLayer/Control/HandR/GreenRing

@onready var raycast : RayCast3D =  $"../Head/Camera3D/RayCast3D"
@onready var redShootSound: AudioStreamPlayer = $HeartSmashed
@onready var blueShootSound: AudioStreamPlayer = $LightningSpell
@onready var greenShootSound: AudioStreamPlayer = $PlantStrike

# === ESTADO ===
var can_shoot: bool = true
var current_ammo: AmmoType = AmmoType.RED

var canRed: bool = false
var canBlue: bool = false
var canGreen: bool = false

func setRedMask() -> void:
	canRed = true
	spriteHandL.visible = true
	spriteHandR.visible = true
	spriteMask.visible = true
	switch_ammo(AmmoType.RED)
	spriteRedRing.visible = true
	
func setBlueMask() -> void:
	canBlue = true
	switch_ammo(AmmoType.BLUE)
	spriteBlueRing.visible = true

func setGreenMask() -> void:
	canGreen = true
	switch_ammo(AmmoType.GREEN)
	spriteGreenRing.visible = true

func _ready() -> void:
	spriteHandL.visible = false
	spriteHandR.visible = false
	spriteMask.visible = false
	
	spriteBlueRing.visible = false
	spriteRedRing.visible = false
	spriteGreenRing.visible = false


func _input(event: InputEvent) -> void:
	# Solo disparar con click izquierdo y si podemos disparar
	if event.is_action_pressed("shoot") and can_shoot:
		shoot()
	
	# Cambio de munición con teclas numéricas
	if event.is_action_pressed("ammo_red") and canRed:
		switch_ammo(AmmoType.RED)
	elif event.is_action_pressed("ammo_blue") and canBlue:
		switch_ammo(AmmoType.BLUE)
	elif event.is_action_pressed("ammo_green") and canGreen:
		switch_ammo(AmmoType.GREEN)
	
	# Cambio de munición con rueda del ratón
	if event.is_action_pressed("ammo_next"):
		next_ammo()
	elif event.is_action_pressed("ammo_prev"):
		prev_ammo()


func shoot() -> void:
	if !can_shoot:
		return;
		
	can_shoot = false

	if current_ammo == AmmoType.BLUE and canBlue:
		spriteHandL.play("BlueAttack")
		blueShootSound.volume_db = -20
		blueShootSound.play()
	elif current_ammo == AmmoType.GREEN and canGreen:
		spriteHandL.play("GreenAttack")
		greenShootSound.volume_db = -5
		greenShootSound.play()
	elif current_ammo == AmmoType.RED and canRed:
		spriteHandL.play("RedAttack")
		redShootSound.volume_db = -20
		redShootSound.play()
		
	if raycast and raycast.is_colliding():
		var collider = raycast.get_collider()
		
		if collider.has_method("take_damage"):
			collider.take_damage(25, current_ammo)

# === SISTEMA DE MUNICIÓN ===

func switch_ammo(ammo_type: AmmoType) -> void:
	if current_ammo != ammo_type:
		if ammo_type == AmmoType.GREEN and canGreen:
			current_ammo = ammo_type
		elif ammo_type == AmmoType.BLUE and canBlue:
			current_ammo = ammo_type
		elif ammo_type == AmmoType.RED and canRed:
			current_ammo = ammo_type
		
		_apply_ammo_color()
		#print("Munición cambiada a: ", AmmoType.keys()[current_ammo])


func next_ammo() -> void:
	var next_type := (current_ammo + 1) % AmmoType.size()
	switch_ammo(next_type as AmmoType)


func prev_ammo() -> void:
	var prev_type := (current_ammo - 1 + AmmoType.size()) % AmmoType.size()
	switch_ammo(prev_type as AmmoType)


func get_current_ammo_type() -> AmmoType:
	return current_ammo
	
func get_can_shoot() -> bool:
	return can_shoot

	
func _apply_ammo_color() -> void:
	if spriteMask and canRed:
		if current_ammo == AmmoType.BLUE and canBlue:
			spriteMask.play("blue")
		elif current_ammo == AmmoType.GREEN and canGreen:
			spriteMask.play("green")
		else:#red
			spriteMask.play("red")
			
		if can_shoot:
			if current_ammo == AmmoType.BLUE and canBlue:
				spriteHandL.play("BlueIdle")
			elif current_ammo == AmmoType.GREEN and canGreen:
				spriteHandL.play("GreenIdle")
			else:#red
				spriteHandL.play("RedIdle")
			
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


func _on_hand_l_animation_finished() -> void:
	can_shoot = true
	
	if current_ammo == AmmoType.BLUE and canBlue:
		spriteHandL.play("BlueIdle")
	elif current_ammo == AmmoType.GREEN and canGreen:
		spriteHandL.play("GreenIdle")
	else:#red
		spriteHandL.play("RedIdle")
