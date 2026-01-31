extends CharacterBody3D

# === MOVIMIENTO ===
@export var SPEED: float = 8.0
@export var SPRINT_SPEED: float = 14.0
@export var ACCELERATION: float = 15.0
@export var DECELERATION: float = 10.0
@export var JUMP_VELOCITY: float = 6.0

# === RATÓN ===
@export var MOUSE_SENS: float = 0.15

# === HEAD BOB ===
@export var BOB_FREQ: float = 2.5
@export var BOB_AMP: float = 0.08
var bob_time: float = 0.0

# === NODOS ===
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var raycast: RayCast3D = $Head/Camera3D/RayCast3D  # Opcional para disparo
@onready var gun: Node3D = $Gun  # Referencia al arma
@onready var footstep_sound: AudioStreamPlayer = $FootstepSound
@onready var footstep_timer: Timer = $FootstepTimer

@onready var health_label: Label = $HealthLayer/Label

# Variables internas
var current_speed: float = SPEED
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var hp: int = 5


func _ready() -> void:
	# Capturar el ratón
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	set_hp(5)
	
func _input(event: InputEvent) -> void:
	# Rotación con el ratón (solo horizontal como Doom clásico)
	if event is InputEventMouseMotion:
		# Rotación horizontal del cuerpo
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENS))
		
		
		head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENS))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-70), deg_to_rad(70))
	
	# Liberar/capturar ratón con ESC
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Disparo
	if event.is_action_pressed("shoot"):
		shoot()


func _physics_process(delta: float) -> void:
	# Gravedad
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Sprint
	if Input.is_action_pressed("sprint"):
		current_speed = SPRINT_SPEED
	else:
		current_speed = SPEED
	
	# Obtener dirección de input
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Movimiento con aceleración/desaceleración suave
	if direction:
		velocity.x = lerp(velocity.x, direction.x * current_speed, ACCELERATION * delta)
		velocity.z = lerp(velocity.z, direction.z * current_speed, ACCELERATION * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, DECELERATION * delta)
		velocity.z = lerp(velocity.z, 0.0, DECELERATION * delta)
	
	# Head bob mientras caminas
	if is_on_floor() and direction:
		bob_time += delta * velocity.length()
		if camera:
			camera.position.y = lerp(camera.position.y, sin(bob_time * BOB_FREQ) * BOB_AMP, 10 * delta)
	else:
		bob_time = 0.0
		if camera:
			camera.position.y = lerp(camera.position.y, 0.0, 10 * delta)
	
	move_and_slide()
	
	# Sonido de pasos
	_handle_footsteps(direction)


func shoot() -> void:
	if raycast and raycast.is_colliding():
		var collider = raycast.get_collider()
		print("¡Impacto en: ", collider.name, "!")
		
		if collider.has_method("take_damage") and gun:
			var ammo_type = gun.get_current_ammo_type()
			collider.take_damage(25, ammo_type)
	else:
		print("¡Disparo al aire!")


func set_hp(value: int):
	hp = value
	gun.update_health_animation(hp)

func die():
	call_deferred("_change_to_menu")

func _change_to_menu():
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
		
func take_damage(amount: int):
	set_hp(hp - amount)
	print("vida: ", hp)
	if hp <= 0:
		die()


func _handle_footsteps(direction: Vector3) -> void:
	# Solo reproducir pasos si está en el suelo, moviéndose, y el timer terminó
	if is_on_floor() and direction and footstep_timer.is_stopped():
		footstep_sound.play()
		footstep_timer.start()
