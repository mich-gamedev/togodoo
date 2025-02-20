extends Control

@onready var tree: Tree = %Tree

var tree_items : Array[TreeItem]
var items : Array[Dictionary]

func _ready() -> void: #TODO: replace with selection later
	FileManager.load_mods()
	var file = FileAccess.open("res://test.txt", FileAccess.READ)


	while file.get_position() < file.get_length():
		var line = file.get_line()
		var parsed = LineParser.parse_line(line)
		items.append(parsed)
	var previous_tree_items: Array[TreeItem]
	tree.set_column_expand(1, false)
	for i in items.size():
		var parent_index = get_parent_from_item(items, i)
		var item := tree.create_item(previous_tree_items[parent_index] if parent_index else null)
		#item.set_expand_right(0, false)
		var config := FileManager.get_block_config(FileManager.block_types[items[i].type])
		if config.has_section("usage"): for arg in config.get_section_keys("usage"):
			if String(config.get_value("usage", arg)).replace(" ", "").split(",").has("title_checkbox"):
				item.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
				item.set_editable(1, true)
				item.set_checked(1, items[i].get(arg))
				item.set_expand_right(1, false)
				item.set_icon_max_width(1, 16)
				break
		item.set_text(0, items[i].stripped_title)
		item.set_expand_right(0, true)
		previous_tree_items.append(item)
	tree_items = previous_tree_items.duplicate()

func get_parent_from_item(items: Array, idx: int) -> int:
	var back_idx := 0
	while back_idx != idx:
		#item[idx].indents <= item[back_idx].indents
		if items[idx].indents > items[idx - back_idx].indents:
			return idx - back_idx
		back_idx += 1
	return 0

func _on_tree_item_selected() -> void:
	var curr_item: int
	for i in tree_items.size():
		tree_items[i].set_editable.call_deferred(0, tree_items[i].is_selected(0))
		if tree_items[i].is_selected(0):
			curr_item = i
	for i in %PropertyList.get_children():
		i.queue_free()
	var config = FileManager.get_block_config(FileManager.block_types[items[curr_item].type])
	if config.has_section("properties"): for i in config.get_section_keys("properties"):
		var usage_tags = config.get_value("usage", i, "none").replace(" ", "").split(",")
		print(usage_tags)
		for tag in usage_tags:
			print(tag)
			if FileManager.usage_types.has(tag):
				var inst = (FileManager.usage_types[tag] as PackedScene).instantiate()
				%PropertyList.add_child(inst)
				inst.get_node("%PropertyName").text = i.replace("_", " ")
				break
#TODO: sync properties tab with actual values
