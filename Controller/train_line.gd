class_name Train_Line

signal player_train_moved(new_loc:Train)

var name:String
var size:int
var transfer_list:Array[String] = []
# Train notation: [position, movement, has_player, train_line_name]
var train_list:Array[Train] = []

func init(s:int, n:String) -> void:
	name = n
	size = s
	for t in size + 1:
		transfer_list.append("None")
	#Start trains at opposite ends
	train_list = []
	train_list.append(Train.new(1,1,name))
	train_list.append(Train.new(size,-1,name))

# Pos is 1-indexed, to use the actual station numbers
func add_transfer(pos:int, transfer_name:String) -> void:
	if pos + 1 < size:
		transfer_list[pos+1] = transfer_name

func check_for_train(pos:int) -> Array:
	var out_list = []
	#print("[train line] Pos = ",pos," and train_list = ",train_list)
	for train in train_list:
		if train.position == pos:
			out_list.append(train)
	return out_list

func player_embark(pos:int, is_ascending:bool):
	for train in train_list:
		if pos == train.position:
			# If the position and direction are right, set has_player to true
			if is_ascending and train.movement_increment == 1:
				train.has_player = true
			elif not(is_ascending) and train.movement_increment == -1:
				train.has_player = true

func player_disembark():
	# Set has_player to false for all trains
	for train in train_list:
		train.has_player = false

func move_trains():
	print("[train line] Moving trains")
	for train in train_list:
		# Move train, turning around if needed
		train.move_train()
		print("[train line] train ", train.train_line_name, " has finished moving to ",train.position,)
		if train.position == 1 or train.position == size:
			train.turn_train_around()
		
		# If player on board
		#print("[train line] has_player = ",train[2])
		if train.has_player:
			#print("[train line] emitting signal")
			player_train_moved.emit(train)
