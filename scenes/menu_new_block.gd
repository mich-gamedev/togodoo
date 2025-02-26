extends Window

signal block_create_pressed(type: String)

var last_type: String

func _ready() -> void:
	for i in FileManager.block_types:
		var config = FileManager.get_block_config(FileManager.block_types[i])
		var inst = Button.new()
		%BlockTypeContainer.add_child(inst)
		inst.text = config.get_value("display", "display_name")
		inst.icon = load(config.get_value("display", "icon"))
		inst.alignment = HORIZONTAL_ALIGNMENT_LEFT
		inst.expand_icon = true
		inst.custom_minimum_size.y = 24
		inst.pressed.connect(_on_block_type_pressed.bind(i))

func _on_block_type_pressed(type: String) -> void:
	var config = FileManager.get_block_config(FileManager.block_types[type])
	%Title.text = config.get_value("display", "display_name")
	%Icon.texture = load(config.get_value("display", "icon"))
	%Credits.text = config.get_value("display", "credit")
	%Description.text = config.get_value("display", "description")
	last_type = type

func _on_close_requested() -> void:
	queue_free()

func _on_create_pressed() -> void:
	block_create_pressed.emit(last_type)
