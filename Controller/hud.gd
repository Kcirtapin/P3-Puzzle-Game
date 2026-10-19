extends CanvasLayer
class_name Hud

@onready var goal_label:Label = $VBoxContainer/Goal_Label
@onready var minute_label:Label = $VBoxContainer/Minute_Time_Label
@onready var second_label:Label = $VBoxContainer/Second_Time_Label

func set_minute_time(m_time:int) -> void:
	minute_label.text = "Time: " + str(m_time/60 + 8)+":%02dam" % [m_time%60]

func set_second_time(s_time:int) -> void:
	second_label.text = str(s_time) + "s"

func set_goal(platform_name:String):
	goal_label.text = "Goal Station: " + str(platform_name)

func end_game(is_win:bool) -> void:
	$End_Container.visible = true
	if is_win:
		$End_Container/End_Label.text = "You made it!\nYou win!"


func _on_exit_button_pressed() -> void:
	get_tree().quit()
