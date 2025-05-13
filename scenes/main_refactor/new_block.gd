extends Button

const MENU_NEW_BLOCK = preload("res://scenes/main_refactor/create_new_block.tscn")

func _pressed() -> void:
	var inst = MENU_NEW_BLOCK.instantiate()
	add_child(inst)
