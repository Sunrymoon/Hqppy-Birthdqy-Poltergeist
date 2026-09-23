extends Node3D

var player 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$MeshInstance3D.rotate(Vector3(0,1,0),0.06)

func grind(body:Area3D):
	player = body.get_parent()

	var player = body.get_parent()
	player.add_vel +=1
	player.velocity.x = player.velocity.x *1.6
	player.velocity.z = player.velocity.z *1.6
	player.velocity.y += -(player.velocity.y)*1.5
	player.move_and_slide()
	%AnimationPlayer.play("broken")
	await %AnimationPlayer.animation_finished
	%AnimationPlayer.play("respawn")

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("foot"):
		grind(area)
		print('3333')
		player.is_on_grind_rail = true
		

func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.is_in_group("foot"):
		player.is_on_grind_rail = false
