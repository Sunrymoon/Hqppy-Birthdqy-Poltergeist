extends Node3D

@onready var head: Node3D = $"../head"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("dropdown"):
		get_parent().BOB_AMP = 0.00
		var tween_TRANS = create_tween()
		tween_TRANS.tween_property(head,"position",Vector3(0.0,0.14,0.0),0.1)

	elif Input.is_action_just_released("dropdown"):
		get_parent().BOB_AMP = 0.08
		var tween_TRANS = create_tween()
		tween_TRANS.tween_property(head,"position",Vector3(0.0,0.85,0.0),0.1)
