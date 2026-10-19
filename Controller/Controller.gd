extends Node2D

class_name Controller

enum color_to_size {GREEN=5,BLUE=6,RED=7,BLACK=8}

@export var train_room:PackedScene
@export var platform_room:PackedScene

@onready var player:Player = $Player
@onready var hud:Hud = $HUD
@onready var timer:Timer = $MinuteTimer

var room:Room = null

var win_con:bool = false

var subway_map:Dictionary[String,Train_Line] = {}
var goal_location:String = ""
var time_elapsed:int = 0

const PREGEN_MAP_DATA:Array = ["Green-X","Green-O","Red-X","Red-O","Black-X","Black-O","Blue-O"]
const PREGEN_TRANSFER_DATA:Dictionary = {
	"Green-X":["Red-O-3","Black-O-7"],
	"Green-O":["Black-X-2"],
	"Red-X":["Red-O-5","Black-O-5", "Blue-O-3"],
	"Red-O":["Green-X-2","Red-X-2"],
	"Black-X":["Green-O-3","Blue-O-5", "Black-O-3"],
	"Black-O":["Black-X-6","Red-X-4", "Green-X-4"],
	"Blue-O":["Red-X-6","Black-X-4"]
	}
const PREGEN_MAP_DATA_2:Array = ["Green-X"]
const PREGEN_TRANSFER_DATA_2:Dictionary = {
	"Green-X":[]
	}

const USE_PREGEN:bool = true
const TIME_LIMIT = 45

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_map()

func _process(delta: float) -> void:
	hud.set_second_time(timer.time_left)

# Populates subway map with the necessary TrainLines
# Adds relevant transfers to all TrainLines
func generate_map() -> void:
	subway_map = {}
	player.on_train = false
	if USE_PREGEN:
		for line in PREGEN_MAP_DATA:
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
			for transfer in PREGEN_TRANSFER_DATA.get(line):
				new_line.add_transfer(transfer_location,transfer)
				transfer_location += 2
			subway_map.set(line,new_line)
			
		player.set_location_platform("Green-X-1")
		#goal_location = "Green-O-5"
		goal_location = "Red-O-4"
		hud.set_goal(goal_location)

# Determines how many and which trains are at the player's platform
# Adds those trains to the room
func check_platform_for_train() -> void:
	if not(player.on_train):
		#print("[main] On platform, looking for trains")
		# Finds the train line and checks for trains at the current station
		var train_line:Train_Line = subway_map.get(player.get_line_name())
		var trains:Array = train_line.check_for_train(player.get_station_number())
		# Checks if there is another line that could have a train here
		if train_line.transfer_list[player.get_station_number()] != "None":
			#print(subway_map.get(train_line.transfer_list[player.get_station_number()].substr(0,train_line.transfer_list[player.get_station_number()].length()-2)).check_for_train(int(train_line.transfer_list[player.get_station_number()].substr(train_line.transfer_list[player.get_station_number()].length()-1))))
			for train in subway_map.get(train_line.transfer_list[player.get_station_number()].substr(0,train_line.transfer_list[player.get_station_number()].length()-2)).check_for_train(int(train_line.transfer_list[player.get_station_number()].substr(train_line.transfer_list[player.get_station_number()].length()-1))):
				trains.append(train)
		#print("[main] Train list:",trains)
		for train in trains:
			room.add_train(train)
	
# Ends the game as a loss
func game_over() -> void:
	hud.end_game(false)

# Ends the game as a victory
func game_won() -> void:
	hud.end_game(true)

# Updates the room based on the room type.
# Updates the time limit counter
func _on_minute_timer_timeout() -> void:
	time_elapsed += 1
	hud.set_minute_time(time_elapsed)
	hud.set_second_time(int(timer.time_left))
	if time_elapsed == TIME_LIMIT:
		game_over()
	for line in subway_map.values():
		line.move_trains()
	room.clear_transitions()
	if player.on_train:
		room.move_stations(player.get_station_number(),player.get_station_number() + player.direction)
		if randi() % 2 == 0:
			room.toggle_gate(true,true)
		else:
			room.toggle_gate(true,false)
	else:
		check_platform_for_train()
	#print(player.location)

# Changes the room to a TrainRoom, specifically the one passed.
func change_room_train(train:Train):
	if room != null:
		room.queue_free()
	var train_line:Train_Line = subway_map.get(train.train_line_name)
	player.set_location_train(train)
	player.on_train = true
	train_line.player_embark(player.get_station_number(),train.movement_increment == 1)
	train_line.player_train_moved.connect(player.set_location_train)
	room = train_room.instantiate()
	call_deferred("add_child",room)
	room.z_index = -1
	player.position = room.player_start_position
	room.set_line_name(player.get_line_name())
	room.move_stations(player.get_station_number(),player.get_station_number() + train.movement_increment)
	room.move_to_platform.connect(change_room_platform)

func change_room_platform(dest:String) -> void:
	if room != null:
		subway_map.get(room.line_name).player_disembark()
		room.queue_free()
	
	if dest == goal_location:
		game_won()
	room = platform_room.instantiate()
	#call_deferred("add_child",room)
	add_child(room)
	room.move_to_train.connect(change_room_train)
	room.z_index = -1
	player.position = room.player_start_position
	player.on_train = false
	room.update_transfer_label(subway_map.get(player.get_line_name()),player.get_station_number())
	check_platform_for_train()

func _on_start_button_pressed() -> void:
	$Button.queue_free()
	$HTPLabel.queue_free()
	$MinuteTimer.start()
	$BGM_Player.play()
	player.visible = true
	change_room_platform(player.location[0])
	
