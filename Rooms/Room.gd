extends TileMapLayer

class_name Room

signal exit_room(new_room:String)

var player_start_pos:Vector2 = Vector2.ZERO
var room_transitions:Array[String] = []
