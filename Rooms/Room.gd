extends TileMapLayer

class_name Room

#signal change_room(new_room:String)

const SOURCE_ID:int = 3
const CLOSED_DOOR:Vector2 = Vector2(1,1)
const OPEN_DOOR:Vector2 = Vector2(0,1)

@export var player_start_position:Vector2 = Vector2.ZERO
var room_transition_dest:String


func set_gate_destination(dest:String) -> void:
	room_transition_dest = dest
