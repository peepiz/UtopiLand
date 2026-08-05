extends Node3D

# Перетащи сюда сцену своего дерева (tree.tscn) из файловой системы в инспекторе
@export var tree_scene: $Cylinder

@export var tree_count: int = 500        # Сколько всего деревьев хотим спавнить
@export var map_size: float = 100.0       # Размер твоей лужайки
@export var clear_radius: float = 5   # Радиус вокруг центра (0,0,0), где деревья НЕ будут спавниться (зона цирка)

func _ready() -> void:
	if not tree_scene:
		print("Забыли прикрепить сцену дерева в инспекторе!")
		return
		
	generate_forest()

func generate_forest() -> void:
	var spawned = 0
	
	while spawned < tree_count:
		# Генерируем случайную позицию X и Z в пределах карты
		var x = randf_range(-map_size / 2, map_size / 2)
		var z = randf_range(-map_size / 2, map_size / 2)
		
		# Считаем расстояние от центра (0, 0), чтобы не заставить деревьями цирк
		var distance_from_center = Vector2(x, z).length()
		
		if distance_from_center > clear_radius:
			# Создаем экземпляр дерева
			var tree = tree_scene.instantiate()
			add_child(tree)
			
			# Задаем позицию
			tree.position = Vector3(x, 0, z)
			
			# Немного случайного поворота, чтобы деревья не выглядели одинаково копипастными
			tree.rotate_y(randf_range(0, PI * 2))
			
			# Рандомим размер (чуть выше, чуть ниже), это добавит живости лесу
			var random_scale = randf_range(0.8, 1.3)
			tree.scale = Vector3(random_scale, random_scale, random_scale)
			
			spawned += 1
