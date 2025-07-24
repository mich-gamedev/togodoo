extends MenuButton

const PREFERENCES = preload("res://scenes/preferences.tscn")
const MOD_MANAGER = preload("res://scenes/mod_manager.tscn")

func _ready() -> void:
	get_popup().index_pressed.connect(_index_pressed)

func _index_pressed(index) -> void:
	match get_popup().get_item_text(index):
		"preferences":
			var inst = PREFERENCES.instantiate()
			get_tree().current_scene.add_child(inst)
			inst.show()
		"open user data folder":
			OS.shell_show_in_file_manager(OS.get_user_data_dir())
		"manage mods":
			var inst = MOD_MANAGER.instantiate()
			get_tree().current_scene.add_child(inst)
			inst.show()
