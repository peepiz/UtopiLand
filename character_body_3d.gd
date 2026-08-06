extends CharacterBody3D

# List of objects
enum ObjectType { CUBE, PLANE, BALL, CONE, NONE }

# what selected in this time(default - CUBE)
var current_selected_type: ObjectType = ObjectType.CUBE

# export variables of scenes
@export var cube_scene: PackedScene
@export var ball_scene: PackedScene
@export var cone_scene: PackedScene
@export var active_object_scene: PackedScene
@export var passive_object_scene: PackedScene


#sprint-jump settings
@export var WALK_SPEED: float = 5.0
@export var SPRINT_SPEED: float = 8.0
@export var BHOP_BOOST: float = 3.0        # additional speed boost pulse while jumping
@export var SPEED_DECAY: float = 2.0        # excess speed decay rate per sec
@export var JUMP_VELOCITY: float = 4.5
var current_speed: float = 5.0

# hint
@onready var press_e_hint: Control = $UI/Label2

# camera3D
@onready var camera = $Camera3D

# FOV settings
const FOV_BASE = 75.0
const FOV_SPRINT = 85.0
const FOV_CHANGE_SPEED = 4

# View Bobbing
const BOB_FREQ_WALK = 2.0
const BOB_FREQ_SPRINT = 3.5
const BOB_AMP_WALK = 0.06
const BOB_AMP_SPRINT = 0.12

# Link on radial menu
@onready var radial_menu = $CanvasLayer/RadialMenu

# mouse sensitivity
var sensitivity = 0.003 

# default value of spwn rate in front of player
@export var spawn_distance: float = 2.0

func _ready() -> void:
	#do 25 fps for playing
	Engine.max_fps = 25
	
	# finds menu
	var menu = $CanvasLayer/RadialMenu
	if menu:
		menu.object_type_changed.connect(_on_menu_type_changed)

func _on_menu_type_changed(new_type: int) -> void:
	current_selected_type = new_type as ObjectType
	print("СИГНАЛ ПОЛУЧЕН! Текущий тип в игроке теперь: ", current_selected_type)

func _process(_delta):
	# if TAB pressed - show the menu
	if Input.is_key_pressed(KEY_TAB):
		if !radial_menu.visible:
			radial_menu.visible = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			# center the mouse before opening
			get_viewport().warp_mouse(get_viewport().size / 2)
	else:
		# if TAB released - hide the menu
		if radial_menu.visible:
			radial_menu.visible = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("toCircus_debug"):
		position.x = -75
		position.y = 3.194
		position.z = -1
	
	# determine the mode - sprint or walk
	var is_sprinting = Input.is_action_pressed("sprint")
	var target_base_speed = SPRINT_SPEED if is_sprinting else WALK_SPEED

	# jump with sprint-jump mechanics
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		# if jumping while holding SHIFT(sprint) - get instant speed boost
		if is_sprinting:
			current_speed += BHOP_BOOST
	
	if is_sprinting == false:
		current_speed = WALK_SPEED
	
	# smooth damping of excess speed to base (Walk/sprint)
	if current_speed > target_base_speed:
		current_speed = move_toward(current_speed, target_base_speed, SPEED_DECAY * delta)
	else:
		current_speed = target_base_speed

	# 5. dynamic change the FOV for the speed effect
	var target_fov = FOV_SPRINT if (is_sprinting or current_speed > SPRINT_SPEED) else FOV_BASE
	camera.fov = lerp(camera.fov, target_fov, FOV_CHANGE_SPEED * delta)

	# 6. WASD
	var input_dir := Input.get_vector("move_left", "move_right", "move_front", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	# insta-reset position(Q button)
	if Input.is_action_just_pressed("reset_pos"):
		global_position = Vector3(0,3,0)
		velocity = Vector3.ZERO
		current_speed = WALK_SPEED
	
	# if QUIT(ESC) pressed - quit the game
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	# processing spawn click(LMB)
	if Input.is_action_just_pressed("spawn_click") and not radial_menu.visible:
		print("--- ONE CLICK OF LMB ---")
		match current_selected_type:
			ObjectType.CUBE:
				spawn_object(cube_scene)
			ObjectType.CONE:
				spawn_object(passive_object_scene)
			ObjectType.PLANE:
				spawn_object(cone_scene)
			ObjectType.BALL:
				spawn_object(ball_scene)

	# processing delete click(RMB)
	if Input.is_action_just_pressed("remove_click") and not radial_menu.visible:
		print("--- ONE CLICK OF RMB ---")
		remove_object()

	move_and_slide()

func _input(event: InputEvent) -> void:
	# mouse rotates a camera
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))

# raycast for object spawn
func spawn_object(object_scene: PackedScene) -> void:
	print("func called @<@")
	if object_scene == null:
		print("WARNING!: object_scene is NULL")
		return
		
	var new_object = object_scene.instantiate()
	
	var space_state = get_world_3d().direct_space_state
	var ray_origin = camera.global_position
	var ray_direction = -camera.global_transform.basis.z.normalized()
	
	var max_ray_distance = 100.0
	var ray_end = ray_origin + (ray_direction * max_ray_distance)
	
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.exclude = [get_rid()] # Игнорируем игрока
	
	var result = space_state.intersect_ray(query)
	var spawn_position: Vector3
	
	var is_plane = (current_selected_type == ObjectType.PLANE)
	var ground_level = global_position.y
	
	if result:
		var hit_point = result.position
		var distance_to_hit = ray_origin.distance_to(hit_point)
		
		if is_plane:
			spawn_position = hit_point
			spawn_position.y = ground_level
		else:
			if distance_to_hit > 5.0:
				spawn_position = ray_origin + (ray_direction * 5.0)
			else:
				spawn_position = hit_point + Vector3(0, 0.5, 0)
	else:
		if is_plane:
			spawn_position = ray_origin + (ray_direction * 1.5)
			spawn_position.y = ground_level
		else:
			spawn_position = ray_origin + (ray_direction * 5.0)
	
	# safety add ONLY ONE obj
	if new_object.get_parent() == null:
		get_tree().current_scene.add_child(new_object)
		new_object.global_transform.origin = spawn_position
		print("object succesfully added to scene at coordinates: ", spawn_position)
		
		if new_object is RigidBody3D:
			new_object.linear_velocity = Vector3.ZERO
			new_object.angular_velocity = Vector3.ZERO

# func of delete an object under crosshair
func remove_object() -> void:
	var space_state = get_world_3d().direct_space_state
	var ray_origin = camera.global_position
	var ray_direction = -camera.global_transform.basis.z.normalized()
	
	var max_ray_distance = 100.0
	var ray_end = ray_origin + (ray_direction * max_ray_distance)
	
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.exclude = [get_rid()]
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var hit_node = result.collider
		
		# finding root of obj
		var object_to_delete = hit_node
		while object_to_delete.get_parent() and object_to_delete.get_parent() != get_tree().current_scene:
			object_to_delete = object_to_delete.get_parent()
		
		# LIST OF PROTECTED NAMES! VERY IMPORTANT!
		var protected_names = ["gnd", "Wall", "Wall2", "Wall3", "Wall4", "roof", "roof2", "roof3", "world", "CircusInside"]
		
		var is_protected = false
		for protected_name in protected_names:
			if object_to_delete.name == name or object_to_delete.name.begins_with(name):
				is_protected = true
				break
		
		# checking is not static body
		if object_to_delete is StaticBody3D or object_to_delete is GridMap:
			is_protected = true
		
		if is_protected:
			print("Trying to delete piece of world!")
			return
		
		# delete everything else
		print("deleting obj: ", object_to_delete.name)
		object_to_delete.queue_free()
	else:
		print("nothing finded")
