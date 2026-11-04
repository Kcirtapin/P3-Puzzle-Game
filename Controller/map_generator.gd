class_name MapGenerator

var goal_location:String
var start_location:String
enum color_to_size {PURPLE=4,GREEN=5,BLUE=6,RED=7,BLACK=8,YELLOW=9}

func generate() -> Dictionary:
	var line_list: Array[String] = []
	var transfer_dict: Dictionary[String, Array] = {}
	start_location = ""
	goal_location = ""
	# balance represents the number of transfers of each type (X or O)
	# positive means there are more X than O transfers (needs an O line)
	# negative means there are more O than X transfers (needs an X line)
	# balance should be 0 at the end of this step
	var balance:int = -1
	# The following lists will contain the transfers for each station type
	# After being built, they will not be modified, only copied
	var x_list_original:Array[String] = []
	var o_list_original:Array[String] = []
	while balance != 0:
		balance = 0
		var num_of_lines: int = randi_range(6,10)
		line_list = []
		x_list_original = []
		o_list_original = []
		while line_list.size() < num_of_lines:
			var potential_line:String = get_random_color_name()
			if balance < 0:
				if line_list.find(potential_line+"-X") == -1:
					line_list.append(potential_line+"-X")
					#print("[map_gen] Adding line to line_list: ", potential_line,"-X")
					# Adds list of transfer stations to x_list
					for station_num in range(2,color_string_to_enum(potential_line),2):
						x_list_original.append(potential_line+"-X-"+str(station_num))
					balance = set_balance(x_list_original,o_list_original)
			elif balance > 0:
				if line_list.find(potential_line+"-O") == -1:
					line_list.append(potential_line+"-O")
					#print("[map_gen] Adding line to line_list: ", potential_line,"-O")

					# Adds list of transfer stations to o_list
					for station_num in range(3,color_string_to_enum(potential_line),2):
						o_list_original.append(potential_line+"-O-"+str(station_num))
					balance = set_balance(x_list_original,o_list_original)
			else:
				if randi_range(0,1) == 0 and line_list.find(potential_line+"-X") == -1:
					line_list.append(potential_line+"-X")
					#print("[map_gen] (50/50) Adding line to line_list: ", potential_line,"-X")
					#print("[map_gen] line_list = ",line_list)
					# Adds list of transfer stations to x_list
					for station_num in range(2,color_string_to_enum(potential_line),2):
						x_list_original.append(potential_line+"-X-"+str(station_num))
					balance = set_balance(x_list_original,o_list_original)
				elif line_list.find(potential_line+"-O") == -1:
					line_list.append(potential_line+"-O")
					#print("[map_gen] (50/50) Adding line to line_list: ", potential_line,"-O")
					#print("[map_gen] line_list = ",line_list)
					# Adds list of transfer stations to o_list
					for station_num in range(3,color_string_to_enum(potential_line),2):
						o_list_original.append(potential_line+"-O-"+str(station_num))
					balance = set_balance(x_list_original,o_list_original)
		# End of initial list building
		# If X lines need added
		if balance < 0:
			# The correction process is probabilitic, so to guard against infinite looping,
			# only 'fail_count' number of loops will happen.
			var fail_count:int = 10
			# This round of corrections tries to find a single line to add that will solve the balance issue
			while fail_count > 0 and balance != 0:
				fail_count -= 1
				var potential_line:String = get_random_color_name()
				if line_list.find(potential_line+"-X") == -1 and balance + ((color_string_to_enum(potential_line) - 2) / 2) + (color_string_to_enum(potential_line) % 2) == 0:
					line_list.append(potential_line+"-X")
					# Adds list of transfer stations to x_list
					for station_num in range(2,color_string_to_enum(potential_line),2):
						x_list_original.append(potential_line+"-X-"+str(station_num))
					balance = set_balance(x_list_original,o_list_original)
			if balance < 0:
				# This round of corrections tries a combination of lines. Much more failure prone, as it isn't exhaustive
				fail_count = 20
				while fail_count > 0 and balance != 0:
					fail_count -= 1
				var potential_line:String = get_random_color_name()
				if line_list.find(potential_line+"-X") == -1 and balance + ((color_string_to_enum(potential_line) - 2) / 2) + (color_string_to_enum(potential_line) % 2) <= 0:
					line_list.append(potential_line+"-X")
					# Adds list of transfer stations to x_list
					for station_num in range(2,color_string_to_enum(potential_line),2):
						x_list_original.append(potential_line+"-X-"+str(station_num))
					balance = set_balance(x_list_original,o_list_original)

		# If O lines need added
		elif balance > 0:
			# The correction process is probabilitic, so to guard against infinite looping,
			# only 'fail_count' number of loops will happen.
			var fail_count:int = 10
			# This round of corrections tries to find a single line to add that will solve the balance issue
			while fail_count > 0 and balance != 0:
				fail_count -= 1
				var potential_line:String = get_random_color_name()
				if line_list.find(potential_line+"-O") == -1 and balance + ((color_string_to_enum(potential_line) - 2) / 2) == 0:
					line_list.append(potential_line+"-O")
					# Adds list of transfer stations to o_list
					for station_num in range(3,color_string_to_enum(potential_line),2):
						o_list_original.append(potential_line+"-O-"+str(station_num))
					balance = set_balance(x_list_original,o_list_original)
			if balance > 0:
				# This round of corrections tries a combination of lines. Much more failure prone, as it isn't exhaustive
				fail_count = 20
				while fail_count > 0 and balance != 0:
					fail_count -= 1
				var potential_line:String = get_random_color_name()
				if line_list.find(potential_line+"-O") == -1 and balance + ((color_string_to_enum(potential_line) - 2) / 2) >= 0:
					line_list.append(potential_line+"-O")
					# Adds list of transfer stations to o_list
					for station_num in range(3,color_string_to_enum(potential_line),2):
						o_list_original.append(potential_line+"-O-"+str(station_num))
					balance = set_balance(x_list_original,o_list_original)
	# End of line_list building
	if o_list_original.size() != x_list_original.size():
		printerr("[map_gen] Transfer lists not properly built:\n\tx_list = ",x_list_original,"\n\to_list = ",o_list_original)
		printerr("[map_gen] balance = ",balance)
		var zero = 0
		zero = zero/zero
	# Start of transfer_dict building
	var test_success:bool = false
	while not(test_success):
		transfer_dict = {}
		var o_list:Array = o_list_original.duplicate_deep()
		var x_list:Array = x_list_original.duplicate_deep()
		#print("[map_gen] line_list = ",line_list)
		#print("[map_gen] x_list = ",x_list_original)
		#print("[map_gen] o_list = ",o_list_original)
		for line in line_list:
			transfer_dict.set(line,[])
		#print("[map_gen] transfer_dict = ",transfer_dict)
		while not(o_list.is_empty()) or not(x_list.is_empty()):
			var x_station:String = x_list.pop_at(randi_range(0,x_list.size()-1))
			var o_station:String = o_list.pop_at(randi_range(0,x_list.size()-1))
			#print("[map_gen] x_station = ", x_station)
			#print("[map_gen] o_station = ", o_station)
			transfer_dict.get(strip_to_line_name(x_station)).append(o_station)
			transfer_dict.get(strip_to_line_name(o_station)).append(x_station)
		
		# Spannability tests - BFS
		var unreached_line_list:Array = line_list.duplicate_deep()
		var current_search_queue:Array = [unreached_line_list[0]]
		# Searches until no more places to search or no more need to search
		while not(unreached_line_list.is_empty()) and not(current_search_queue.is_empty()):
			var current_line:String = current_search_queue.pop_front()
			if unreached_line_list.find(current_line) != -1:
				unreached_line_list.pop_at(unreached_line_list.find(current_line))
				# Adds reachable lines to the search queue
				for line in transfer_dict.get(current_line):
					current_search_queue.push_back(strip_to_line_name(line))
		if unreached_line_list.is_empty():
			test_success = true
	
	# End of transfer_dict building
	# Start of endpoint determination
	# Repurposing test_sucess for endpoint determination
	test_success = false
	# To account for the chance of a map with no set of valid endpoints
	var num_of_attempts: = 0
	const LOWER_TIME_BOUND:int = 15
	const UPPER_TIME_BOUND:int = 25
	while not(test_success) and num_of_attempts < 50:
		num_of_attempts += 1
		start_location = line_list.pick_random() + "-1"
		goal_location = line_list.pick_random()
		goal_location = goal_location + "-" + str(color_string_to_enum(goal_location.split("-")[0]))
		var time_taken:int = calculate_time_between_points(line_list,transfer_dict,start_location,goal_location)
		#print("[map_gen] time_taken = ",time_taken)
		test_success = LOWER_TIME_BOUND <= time_taken and UPPER_TIME_BOUND >= time_taken
	# Tail recursion in case of failure
	if not(test_success):
		return generate()
	# End of endpoint determination
	return generate_from_pregen(line_list,transfer_dict,start_location,goal_location)

func generate_from_pregen(map_data:Array, transfer_data:Dictionary, start:String, goal:String) -> Dictionary[String,Train_Line]:
	var out_map:Dictionary[String,Train_Line] = {}
	for line in map_data:
		var new_line = Train_Line.new()
		var line_size: int = color_string_to_enum(line.split("-")[0])
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

func color_enum_to_string(enm:color_to_size) -> String:
	return color_to_size.keys()[enm-4].capitalize()

func color_string_to_enum(s:String)-> color_to_size:
	return color_to_size.get(s.to_upper())

func get_random_color_name() -> String:
	return color_enum_to_string(randi_range(4,9))

func strip_to_line_name(station:String) -> String:
	return station.split("-")[0] + "-" + station.split("-")[1]

# Assumes starting point is a platform 1 of some variety
func calculate_time_between_points(line_list:Array, transfer_list:Dictionary, start_pos:String, end_pos:String) -> int:
	#print("[map_gen] start_pos = ",start_pos,"\tend_pos = ",end_pos)
	#print("[map_gen] transfer_list = ",transfer_list)
	var train_list:Array[Train] = []
	for line in line_list:
		train_list.append(Train.new(1,1,line))
		train_list.append(Train.new(color_string_to_enum(line.split("-")[0]),-1,line))
	var time:int = 0
	var found_exit:bool = false
	# pos format: [string "Color-X/O-num", int increment
	var pos_list:Array = [[start_pos,1]]
	var prev_pos_list:Array = []
	while not(found_exit) and not(pos_list.is_empty()):
		time += 1
		#print("\n[map_gen] pos_list = ",pos_list)
		for train in train_list:
			var del_from_pos_list: Array = []
			var add_to_pos_list:Array = []
			#print("[map_gen] pos_list = ",pos_list)
			#print("[map_gen] prev_pos_list = ",prev_pos_list,"\n")
			#if time > 20:
				#print("\n[map_gen] crnt train: ",train.get_position_name())
			for pos in pos_list:
				if (pos[0] == train.get_position_name() and pos[1] == train.movement_increment):
					# Move the pos
					if prev_pos_list.find(strip_to_line_name(pos[0])+ "-" + str(int(pos[0].split("-")[2]) + pos[1])) != -1:
						#print("[map_gen] Already been to ",pos)
						del_from_pos_list.append(pos)
						pos = [null]
					else:
						prev_pos_list.append(pos[0])
						pos[0] = strip_to_line_name(pos[0])+ "-" + str(int(pos[0].split("-")[2]) + pos[1])
					# If the pos equals the goal, found exit
					if pos[0] != null and pos[0] == end_pos:
						return time
					# If the train needs to turn around, delete pos
					if pos[0] != null and ((int(pos[0].split("-")[2]) >= color_string_to_enum(pos[0].split("-")[0]) and pos[1] == 1) or (int(pos[0].split("-")[2]) <= 1 and pos[1] == -1)):
						#print("[map_gen] Deleting pos")
						del_from_pos_list.append(pos)
						pos = [null]
					# If there is a transfer at this station, create 2 new pos
					if pos[0] != null and get_station_transfer(transfer_list, pos[0]) != "":
						#print("[map_gen] get_station_transfer = ",get_station_transfer(transfer_list, pos[0]))
						add_to_pos_list.append([get_station_transfer(transfer_list, pos[0]),1])
						add_to_pos_list.append([add_to_pos_list.back()[0],-1])
				elif int(pos[0].split("-")[2]) == color_string_to_enum(pos[0].split("-")[0]):
					if pos[0] == end_pos:
						return time
					#print("[map_gen] Deleting pos ",pos)
					#print("[map_gen] The string ",pos[0].split("-")[0], " turned into ",color_string_to_enum(pos[0].split("-")[0]), " and was compared to ",pos[0].split("-")[2],"\n")
					del_from_pos_list.append(pos)
					
					
			while not(del_from_pos_list.is_empty()):
				#print("[map_gen] to be deleted: ",del_from_pos_list.front())
				#print("[map_gen] pos list before deletion: ",pos_list)
				pos_list.remove_at(pos_list.find(del_from_pos_list.pop_front()))
				#print("[map_gen] pos list after deletion: ",pos_list)
			while not(add_to_pos_list.is_empty()):
				pos_list.append(add_to_pos_list.pop_front())
			train.move_train()
			if train.position == color_string_to_enum(train.train_line_name.split("-")[0]) or train.position == 0:
				train.turn_train_around()
	
	#print("[map_gen] found_goal = ",found_exit)
	#print("[map_gen] pos_list is empty = ",pos_list.is_empty())
	return -1



func get_station_transfer(transfer_list:Dictionary, station:String) -> String:
	for line in transfer_list.keys():
		var transfers:Array = transfer_list.get(line)
		for transfer_ind in range(transfers.size()):
			if transfers[transfer_ind] == station:
				if line.split("-")[1] == "X":
					return line + "-" + str(2 + (2 * transfer_ind))
				else:
					return line + "-" + str(3 + (2 * transfer_ind))
	return ""

#func check_balance(balance:int, x_list:Array, o_list:Array) -> bool:
	#if balance != x_list.size() - o_list.size():
		#printerr("[map_gen] balance currently incorrect: balance = ",balance,"\n x_list = ",x_list,"\n x_list length = ",x_list.size(),"\no_list = ",o_list,"\n o_list length = ",o_list.size())
		#var zero = 0
		#zero = zero/zero
	##else:
		##print("[map_gen] All clear on balance")
	#return balance == x_list.size() - o_list.size()

func set_balance(x_list:Array,o_list:Array) -> int:
	return x_list.size() - o_list.size()
