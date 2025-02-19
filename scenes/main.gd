extends Control

@onready var tree: Tree = %Tree

func _ready() -> void: #TODO: replace with selection later
	FileManager.load_mods()
	var file = FileAccess.open("res://test.txt", FileAccess.READ)

	var items : Array[Dictionary]
	while file.get_position() < file.get_length():
		var line = file.get_line()
		var parsed = LineParser.parse_line(line)
		items.append(parsed)
	var previous_tree_items: Array[TreeItem]
	for i in items.size():
		var parent_index = get_parent_from_item(items, i)
		var item := tree.create_item(previous_tree_items[parent_index] if parent_index else null)
		#item.set_expand_right(0, false)
		var config := FileManager.get_block_config(FileManager.block_types[item.type])
		for arg in config.get_section_keys("usage"):
			if config.get_value("usage", arg) == "title_checkbox":
				item.set_editable(0, true)
				item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		item.set_text(0, items[i].stripped_title)
		#item.set_expand_right(2, false)
		previous_tree_items.append(item)

func get_parent_from_item(items: Array, idx: int) -> int:
	var back_idx := 0
	while back_idx != idx:
		#item[idx].indents <= item[back_idx].indents
		if items[idx].indents > items[idx - back_idx].indents:
			return idx - back_idx
		back_idx += 1
	return 0
