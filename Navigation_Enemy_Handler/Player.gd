extends CharacterBody3D


const SPEED = 14.0
const JUMP_VELOCITY = 10.0

const ACC = 0.8
const DEC = 0.5

var def_sen_x : float = 0.2
var def_sen_y : float = 0.2

var sensitivity_x : float = def_sen_x
var sensitivity_y : float = def_sen_y

var fps_actice = false
var ghost_mode = false


@onready var head :Node3D= $Head
@onready var viewport_start_size := Vector2(
	ProjectSettings.get_setting(&"display/window/size/viewport_width"),
	ProjectSettings.get_setting(&"display/window/size/viewport_height")
)
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 24.0

func _ready():
	Engine.max_fps = 144
	DisplayServer.window_set_min_size(Vector2(800,450))
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().get_root().find_child("UI",true,false).find_child("CanvasLayer",true,false).visible = fps_actice

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var viewport_sensy = viewport_start_size.x / get_tree().root.get_content_scale_size().x
		rotate_y(deg_to_rad(-event.relative.x * sensitivity_y * viewport_sensy))
		head.rotate_x(deg_to_rad(-event.relative.y * sensitivity_x * viewport_sensy))
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-60),deg_to_rad(45))
	if event.is_action_pressed("spawn"):
		for i in range(10):
			get_tree().get_root().find_child("Map_01",true,false).find_child("NavigationRegion3D",false,false).find_child("Spawns",false,false).enemy_spawn()
	if event.is_action_pressed("ui_text_backspace"):
		print("backspace")
	if event.is_action_pressed("esc"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE )
	if event.is_action_pressed("fps_limit"):
		Engine.max_fps = 144 if Engine.max_fps == 0 else 0
	if event.is_action_pressed("ghost"):
		ghost_mode = !ghost_mode
		@warning_ignore("incompatible_ternary")
		set_collision_mask(pow(2,1-1) + (pow(2,3-1) if !ghost_mode else 0))
	if event.is_action_pressed("t"):
		fps_actice = !fps_actice
		get_tree().get_root().find_child("UI",true,false).find_child("CanvasLayer",true,false).visible = fps_actice

func _physics_process(delta):
	if fps_actice:
		get_tree().get_root().find_child("UI",true,false).find_child("Label",true,false).text = str(Engine.get_frames_per_second())+" FPS\n" + str(get_tree().get_root().find_child("AE",false,false).get_child_count(false))+" Enemy"
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_pressed("space"):
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("a", "d", "w", "s")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = move_toward(velocity.x, direction.x*SPEED, ACC)
		velocity.z = move_toward(velocity.z, direction.z*SPEED, ACC)
	else:
		velocity.x = move_toward(velocity.x, 0, DEC)
		velocity.z = move_toward(velocity.z, 0, DEC)

	move_and_slide()
