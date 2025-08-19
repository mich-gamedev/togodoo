extends CheckBox

@onready var h_box: HBoxContainer = $".."

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if h_box.get_global_rect().has_point(event.global_position):
			show()
		elif !button_pressed: hide()
