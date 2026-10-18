extends Room

signal move_to_platform(dest:String)

var line_name:String
var current_station_num:int

func set_line_name(line:String):
	line_name = line

func clear_transitions() -> void:
	toggle_gate(false,false)
	toggle_gate(false,true)

func move_stations(new_station:int,next_station:int):
	#print("[train room] move stations")
	current_station_num = new_station
	$Label.text = "Current Station:\n"+str(new_station)+"\nNext Station:"+str(next_station)

func toggle_gate(make_open:bool, is_left:bool, station:String=""):
	var x_pos:int = 6
	var y_pos:int = 2
	if is_left:
		x_pos = 0
	var atlas_coord:Vector2 = CLOSED_DOOR
	if make_open:
		atlas_coord = OPEN_DOOR
	for tile in range(3):
		set_cell(Vector2(x_pos,y_pos+tile),SOURCE_ID,atlas_coord)
	
	#transition_list[platform_num] = train

func _on_either_door_body_entered(_body: Node2D) -> void:
	print("[train room] exit door entered")
	move_to_platform.emit(line_name +"-"+ str(current_station_num))
