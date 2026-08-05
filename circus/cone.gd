extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	await get_tree().create_timer(1.0).timeout
	position.x = round(randf_range(0,190))
	await get_tree().create_timer(1.0).timeout
	position.y = round(randf_range(0, 25))
	await get_tree().create_timer(1.0).timeout
	position.z = round(randf_range(0, 190))
	await get_tree().create_timer(1.0).timeout
	
