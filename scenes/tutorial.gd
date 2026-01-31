extends Node3D
@onready var audio := AudioStreamPlayer.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	audio.stream = load("res://assets/decoration/resources/audios/Prologo Chaman.mp3")
	add_child(audio)
	var area = get_child(0).get_child(5)
	area.queue_free()
	audio.play()
	
	pass # Replace with function body.
