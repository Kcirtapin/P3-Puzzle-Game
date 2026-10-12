extends CharacterBody2D
class_name Player

# Location = [station_name, direction]
# Example location: player.location = ["Green-X-1",0]
var location:Array = []
var on_train:bool = false

const SPEED:float = 15000.0

func _physics_process(delta: float) -> void:
	if visible:
		velocity = Input.get_vector("left","right","up","down") * delta * SPEED
		move_and_slide()

func get_station_number() -> int:
	#print(location)
	return int(location[0].split("-")[2])

func get_platform_name() -> String:
	return location[0]

func get_line_name() -> String:
	return location[0].substr(0,location[0].length()-2)
	
func set_location(new_loc:Array) -> void:
	print("[player] old location = ",location," new location = ", new_loc)
	location = new_loc
