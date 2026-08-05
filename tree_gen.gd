extends Node3D

# scene of tree
@export var tree_scene: PackedScene = preload("res://tree.tscn")

@export var tree_count: int = 300          # tree count
@export var map_size: float = 150.0       # size of land
@export var clear_radius: float = 5.0    # radius aorund 0,0,0 where trees NOT spwning

func _ready() -> void:
	if not tree_scene:
		print("forget add tree scene!")
		return
		
	generate_forest()

func generate_forest() -> void:
	var spawned = 0
	
	while spawned < tree_count:
		# generating a random position
		var x = randf_range(-map_size / 2, map_size / 2)
		var z = randf_range(-map_size / 2, map_size / 2)
		
		var distance_from_center = Vector2(x, z).length()
		
		if distance_from_center > clear_radius:
			# making a copy of tree
			var tree = tree_scene.instantiate()
			add_child(tree)
			
			# stting position
			tree.position = Vector3(x, 0, z)
			
			# some random rotation
			tree.rotate_y(randf_range(0, PI * 2))
			
			# generating scale
			var random_scale = randf_range(0.8, 2)
			tree.scale = Vector3(random_scale, random_scale, random_scale)
			
			spawned += 1
