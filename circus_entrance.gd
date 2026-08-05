extends Area3D

@export_file("*.tscn") var circus_scene_path: String = "res://circus_inside.tscn"

var player_node: CharacterBody3D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_node = body
		
		# checking is we have a hint and making it visible
		if "press_e_hint" in player_node and player_node.press_e_hint:
			player_node.press_e_hint.visible = true
			
		print("Player near to door! enabling hint...")

func _on_body_exited(body: Node3D) -> void:
	if body == player_node:
		# before player leaves, hide hint back
		if player_node and "press_e_hint" in player_node and player_node.press_e_hint:
			player_node.press_e_hint.visible = false
			
		player_node = null
		print("the player moved avay from doors. disabling hint...")

func _process(_delta: float) -> void:
	if player_node and Input.is_action_just_pressed("interact"):
		# just in case, hiding hint before changing scene
		if "press_e_hint" in player_node and player_node.press_e_hint:
			player_node.press_e_hint.visible = false
			
		enter_circus()

func enter_circus() -> void:
	var error = get_tree().change_scene_to_file(circus_scene_path)
	if error != OK:
		print("Scene error!: ", error)
