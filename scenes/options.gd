extends MenuButton

const PREFERENCES = preload("res://scenes/preferences.tscn")

func _ready() -> void:
	get_popup().index_pressed.connect(_index_pressed)

func _index_pressed(index) -> void:
	match get_popup().get_item_text(index):
		"preferences":
			var inst = PREFERENCES.instantiate()
			Main.node.add_child(inst)
			inst.show()
