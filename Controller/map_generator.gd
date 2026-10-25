class_name MapGenerator

var goal_location:String
var start_location:String
enum color_to_size {GREEN=5,BLUE=6,RED=7,BLACK=8}

func generate() -> Dictionary:
	return {}

func generate_from_pregen(map_data:Array, transfer_data:Dictionary, start:String, goal:String) -> Dictionary[String,Train_Line]:
	var out_map:Dictionary[String,Train_Line] = {}
	for line in map_data:
		var new_line = Train_Line.new()
		var line_size: int = 0
		if line.split("-")[0] == "Green":
			line_size = color_to_size.GREEN
		elif line.split("-")[0] == "Blue":
			line_size = color_to_size.BLUE
		elif line.split("-")[0] == "Red":
			line_size = color_to_size.RED
		elif line.split("-")[0] == "Black":
			line_size = color_to_size.BLACK
		new_line.init(line_size, line)
		var transfer_location:int = 1
		if line.split("-")[1] == "O":
			transfer_location = 2
		for transfer in transfer_data.get(line):
			new_line.add_transfer(transfer_location,transfer)
			transfer_location += 2
		out_map.set(line,new_line)
	start_location = start
	goal_location = goal
	return out_map

func get_goal_location() -> String:
	return goal_location

func get_start_location() -> String:
	return start_location
