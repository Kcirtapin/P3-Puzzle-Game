extends RigidBody2D

class_name Crowd

var start_pos:Vector2
var end_pos:Vector2
var progress_percent:float = 0.0
var is_moving:bool = false
@export var auto_reverse:bool = false
@export var SPEED:float = 0.4

func start_path(s_pos:Vector2, e_pos:Vector2) -> void:
	start_pos = s_pos
	end_pos = e_pos
	position = start_pos
	is_moving = true
	progress_percent = 0.0

func reverse_path() -> void:
	start_path(end_pos,start_pos)

func _process(delta: float) -> void:
	if is_moving:
		progress_percent += delta * SPEED
		if progress_percent >= 1.0:
			progress_percent = 1.0
			is_moving = false
			if auto_reverse:
				reverse_path()
				return
		position = start_pos.lerp(end_pos,progress_percent)
