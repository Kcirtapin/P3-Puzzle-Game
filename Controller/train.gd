class_name Train

var train_line_name:String
var position:int
var has_player:bool
var movement_increment:int

func _init(pos:int, move:int, name:String) -> void:
	train_line_name = name
	position = pos
	movement_increment = move
	has_player = false
	
func move_train() -> void:
	position += movement_increment

func turn_train_around() -> void:
	movement_increment *= -1
