extends CharacterBody3D

# At the top of your player script

var tar
@export var slide_speed: float = 8.0
@export var max_slope_angle: float = 45.0  # degrees, anything steeper triggers sliding
var gravity: float = 47.8
var sensitivity = 0.01
var SPEED = 9.0
var JUMP_VELOCITY = 13.5
var slope = false
var decel = 7
var accel = 9
var add_vel:float = 0
var is_on_grind_rail = false
@onready var ray_cast_3d: RayCast3D = $head/Camera3D/RayCast3D
@onready var head: Node3D = $head
@onready var camera_3d: Camera3D = $head/Camera3D
#bob variables
const BOB_FREQ = 2.4
var BOB_AMP = 0.08
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitivity)
		camera_3d.rotate_x(-event.relative.y * sensitivity)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x,deg_to_rad(-90),deg_to_rad(90))

func is_on_slope() -> bool:
	if not is_on_floor():
		return false
	var normal = get_floor_normal()
	return normal.angle_to(Vector3.UP) > 0.01  # small threshold to ignore floating point noise

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if Input.is_action_just_pressed("unbind") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif Input.is_action_just_pressed("unbind") and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$CanvasLayer/Label5.text = str(decel)
	$CanvasLayer/Label3.text = str(is_on_grind_rail)
	$CanvasLayer/Label2.text = str(add_vel)
	$CanvasLayer/Label4.text = str(is_on_slope())
	if is_on_slope():
		velocity.y = -add_vel*2
	if add_vel > 0:
		if is_on_floor():
			add_vel = lerp(add_vel,0.0,0.008)
		else:
			add_vel = lerp(add_vel,0.0,0.004)
	if is_on_slope() and Input.is_action_pressed("dropdown") :
		slope =true
		add_vel += 0.2
		if is_on_floor() and !is_on_slope():
			velocity.x += velocity.y
	elif Input.is_action_pressed('dropdown') and !is_on_slope() and is_on_floor() and add_vel > 2:
		add_vel -= 0.3
	if Input.is_action_just_pressed("dropdown"):
		if add_vel > 1:
			add_vel += 3
		velocity.y = -32-add_vel
	if Input.is_action_just_pressed("close"):
		get_tree().quit()
	# Add the gravity.
	if not is_on_floor() and is_on_grind_rail == false: 
		velocity.y -= gravity * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() or Input.is_action_just_pressed("jump") and is_on_grind_rail == true:
		if is_on_slope():
			velocity.y = JUMP_VELOCITY+add_vel
		elif is_on_grind_rail == true:
			velocity.y = JUMP_VELOCITY+add_vel
		elif !is_on_slope():
			velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if is_on_floor():
		if direction and !is_on_slope():
			velocity.x = lerp(velocity.x,direction.x * (SPEED+add_vel),delta*accel)
			velocity.z = lerp(velocity.z,direction.z * (SPEED+add_vel),delta*accel)
		elif is_on_slope() :
			var slide_dir = get_floor_normal().slide(Vector3.UP).normalized()
			if Input.is_action_pressed("dropdown"):
				velocity.x = lerp(velocity.x,slide_dir.x * add_vel,delta*accel)
				velocity.z = lerp(velocity.z,slide_dir.z* add_vel,delta*accel)
			elif direction:
				velocity.x = lerp(velocity.x,direction.x * SPEED,delta*accel)
				velocity.z = lerp(velocity.z,direction.z * SPEED,delta*accel)
			else :
				velocity.x = lerp(velocity.x,direction.x * (SPEED+add_vel),delta*4.5)
				velocity.z= lerp(velocity.z,direction.z * (SPEED+add_vel),delta*4.5)
		else:
			velocity.x = lerp(velocity.x,direction.x * SPEED,delta*decel)
			velocity.z= lerp(velocity.z,direction.z * SPEED,delta*decel)
	else :
		velocity.x = lerp(velocity.x,direction.x * (SPEED+add_vel),delta*4.5)
		velocity.z= lerp(velocity.z,direction.z * (SPEED+add_vel),delta*4.5)
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera_3d.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, (SPEED + add_vel) )
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera_3d.fov = lerp(camera_3d.fov, target_fov, delta * 8.0)
	
	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group('ice'):
		decel = 0.9
		accel = 0.6
		SPEED = 16

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group('ice'):
		decel = 7
		accel = 9
		SPEED = 9
