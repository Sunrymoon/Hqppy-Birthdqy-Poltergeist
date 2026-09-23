extends Node3D
var boost = 28
var add_vel_boost = 0.3

var player 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func grind(body:Area3D):
	player = body.get_parent()
	
	player.velocity.y = 0
	var tar = $Marker3D.global_position
	var player = body.get_parent()
	var dir = (tar-player.global_position)
	

	player.velocity = dir.normalized() * boost * (1+(player.add_vel/12))
	player.add_vel +=add_vel_boost
	player.move_and_slide()
	

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("foot"):
		grind(area)
		print('3333')
		player.is_on_grind_rail = true
		%Marker3D.position = Vector3(0,0,7.889)

func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.is_in_group("foot"):
		player.is_on_grind_rail = false


func _on_area_3d_2_area_entered(area: Area3D) -> void:
	if area.is_in_group("foot"):
		grind(area)
		print('3333')
		player.is_on_grind_rail = true
		%Marker3D.position = Vector3(0,0,-0.723)


func _on_area_3d_2_area_exited(area: Area3D) -> void:
	if area.is_in_group("foot"):
		player.is_on_grind_rail = false
