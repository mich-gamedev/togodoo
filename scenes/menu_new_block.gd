extends Window

signal block_create_pressed(type: String)

var last_type: String

var iterated_sections: Array[String]

const SEPERATOR = preload("res://scenes/new_block_type_seperator.tscn")
const BLOCK_TYPE = preload("res://scenes/new_block_type.tscn")

func _ready() -> void:
	for i: String in FileManager.block_types:
		var config = FileManager.get_block_config(FileManager.block_types[i])
		var section = FileManager.block_types[i].trim_prefix("res://").get_slice("/", 1)
		if !(section in iterated_sections):
			print(section)
			var separator = SEPERATOR.instantiate()
			%BlockTypeContainer.add_child(separator)
			separator.get_node(^"%TypeLabel").text = section.to_pascal_case()
			iterated_sections.append(section)
		var inst = BLOCK_TYPE.instantiate()
		%BlockTypeContainer.add_child(inst)
		var button = inst.get_node(^"%Button")
		button.text = config.get_value("display", "display_name")
		button.icon = load(config.get_value("display", "icon"))
		button.custom_minimum_size.y = 24
		button.pressed.connect(_on_block_type_pressed.bind(i))
		inst.get_node(^"%Favorite").toggled.connect(_on_favorite_toggled.bind(i))

func _on_block_type_pressed(type: String) -> void:
	var config = FileManager.get_block_config(FileManager.block_types[type])
	%Title.text = config.get_value("display", "display_name")
	%Icon.texture = load(config.get_value("display", "icon"))
	%Credits.text = config.get_value("display", "credit")
	%Description.text = config.get_value("display", "description")
	last_type = type

func _on_favorite_toggled(toggled_on: bool, type: String) -> void:
	var array : Array = Array(Settings.get_setting("vanilla", "editor/favorite_blocks"))
	if toggled_on:
		array.append(type)
	else:
		array.erase(type)
	Settings.set_setting("vanilla", "editor/favorite_blocks", array)
	Settings.save_config("vanilla")
	PropertyBus.favorite_block_changed.emit(array)

func _on_close_requested() -> void:
	queue_free()

func _on_create_pressed() -> void:
	block_create_pressed.emit(last_type)
	queue_free()
