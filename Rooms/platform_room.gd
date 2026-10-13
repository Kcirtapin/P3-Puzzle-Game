extends Room

signal move_to_train(train)

var transition_list:Array = [null,[],[],[],[]]
@onready var label_list:Array = [null,$Platform1,$Platform2,$Platform3,$Platform4]

func _ready() -> void:
	player_start_position = Vector2(300,350)

func add_train(train:Array) -> void:
	var platform:int = 1
	while platform < 4 and transition_list[platform] != []:
		platform += 1
	toggle_gate(true,platform,train)
	pass

func clear_transitions() -> void:
	for platform in range(1,transition_list.size()):
		if transition_list[platform] != []:
			toggle_gate(false,platform)

func toggle_gate(make_open:bool, platform_num:int, train:Array=[]):
	var x_pos:int = 16
	var y_pos:int = 15
	if platform_num%2 == 1:
		x_pos = 2
	if platform_num < 3:
		y_pos = 3
	var atlas_coord:Vector2 = CLOSED_DOOR
	if make_open:
		atlas_coord = OPEN_DOOR
	for tile in range(3):
		set_cell(Vector2(x_pos,y_pos+tile),SOURCE_ID,atlas_coord)
	
	transition_list[platform_num] = train
	change_platform_label(platform_num,train)

func change_platform_label(plat:int,train:Array=[]) -> void:
	if plat >= 1 and plat <= 4:
		if train == []:
			label_list[plat].text = "Platform " + str(plat)
		else:
			if train[1] == 1:
				label_list[plat].text = "Platform " + str(plat) + "\n" + train[3].split("-")[0] + " Line train\nAscending station order"
			else:
				label_list[plat].text = "Platform " + str(plat) + "\n" + train[3].split("-")[0] + " Line train\nDescending station order"
	pass

func _on_door_1_body_entered(_body: Node2D) -> void:
	move_to_train.emit(transition_list[1])

func _on_door_2_body_entered(_body: Node2D) -> void:
	move_to_train.emit(transition_list[2])

func _on_door_3_body_entered(_body: Node2D) -> void:
	move_to_train.emit(transition_list[3])

func _on_door_4_body_entered(_body: Node2D) -> void:
	move_to_train.emit(transition_list[4])
