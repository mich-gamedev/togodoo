class_name CustomHSplitContainer extends HSplitContainer

#func _ready() -> void:
	#(get_child(2, true) as Control).scale = Vector2.ONE * .5
