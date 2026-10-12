extends Node2D

class_name Controller

enum color_to_size {GREEN=5,BLUE=6,RED=7,BLACK=8}

@export var train_room:PackedScene
@export var platform_room:PackedScene

@onready var player:Player = $Player
var room:Room = null

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
const USE_PREGEN:bool = true
const TIME_LIMIT = 40

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_map()

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
			var transfer_location:int = 2
			if line.split("-")[1] == "O":
				transfer_location = 3
			for transfer in PREGEN_TRANSFER_DATA.get(line):
				new_line.add_transfer(transfer_location,transfer)
				transfer_location += 2
			subway_map.set(line,new_line)
			
		player.location = ["Green-X-1",0]
		goal_location = "Green-O-5"

func check_platform_for_train() -> void:
	subway_map.get(player.get_line_name()).check_for_train(player.get_station_number())
	pass

func game_over() -> void:
	print("You were late. You lose")
	get_tree().quit()

func game_won() -> void:
	print("You made it! You win!")
	get_tree().quit()

func _on_minute_timer_timeout() -> void:
	time_elapsed += 1
	if time_elapsed == TIME_LIMIT:
		game_over()
	for line in subway_map.values():
		line.move_trains()
	room.clear_transitions()

func change_room_platform(dest:String) -> void:
	if dest == goal_location:
		game_won()
	room = platform_room.instantiate()
	add_child(room)
	room.z_index = -1
	player.position = room.player_start_position

func _on_start_button_pressed() -> void:
	$Button.queue_free()
	player.visible = true
	change_room_platform(player.location[0])
	
