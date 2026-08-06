extends Node3D

func _ready():
	for child in get_children():
		if child is StaticBody3D or child is GridMap:
			child.add_to_group("static")
			print("Защищён: ", child.name)
