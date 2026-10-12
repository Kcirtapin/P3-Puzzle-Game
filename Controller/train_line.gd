class_name Train_Line

signal move_by_train(new_loc:Array)

var name:String
var size:int
var transfer_list:Array[String] = []
# Train notation: [position, movement, has_player, train_line_name]
var train_list:Array = []

func init(s:int, n:String) -> void:
	name = n
	size = s
	for t in size + 1:
		transfer_list.append("None")
	
	#Start trains at opposite ends
	train_list.append([1,1,false,name])
	train_list.append([size+1,-1,false,name])

# Pos is 1-indexed, to use the actual station numbers
func add_transfer(pos:int, transfer_name:String) -> void:
	if pos + 1 < size:
		transfer_list[pos+1] = transfer_name

func check_for_train(pos:int) -> Array:
	var out_list = []
	#print("[train line] Pos = ",pos," and train_list = ",train_list)
	for train in train_list:
		if train[0] == pos:
			out_list.append(train)
	return out_list

func player_embark(pos:int, is_ascending:bool):
	for train in train_list:
		if pos == train[0]:
			# If the position and direction are right, set has_player to true
			if is_ascending and train[1] == 1:
				train[2] = true
			elif not(is_ascending) and train[1] == -1:
				train[2] = true

func player_disembark():
	# Set has_player to false for all trains
	for train in train_list:
		train[2] = false

func move_trains():
	#print("[train line] Moving trains")
	for train in train_list:
		# Move train, turning around if needed
		train[0] += train[1]
		if train[0] == 1 or train[0] == size:
			train[1] *= -1
		
		# If player on board
		#print("[train line] has_player = ",train[2])
		if train[2]:
			#print("[train line] emitting signal")
			move_by_train.emit([name+"-"+str(train[0]),train[1]])
