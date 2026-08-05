extends MeshInstance3D

var speed = 2.0

var t = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var amplX = 5
	var amplZ = 4
	
	t += delta * speed
	
	var x = amplX * sin(t)
	var z = amplZ * sin(2*t)
	var y = 8.0
	
	position = Vector3(x,y,z)
