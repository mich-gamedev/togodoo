extends Control

@onready var tree: Tree = %Tree

var tree_items : Array[TreeItem]
var items : Array[Dictionary]

var curr_item: int

const MENU_NEW_BLOCK = preload("res://scenes/menu_new_block.tscn")

var curr_new_block_window: Window

func _ready() -> void: #TODO: replace with selection later
	FileManager.load_mods()
	var file = FileAccess.open("res://test.txt", FileAccess.READ)
	PropertyBus.property_changed.connect(_on_property_changed)

	while file.get_position() < file.get_length():
		var line = file.get_line()
		var parsed = LineParser.parse_line(line)
		items.append(parsed)
	var previous_tree_items: Array[TreeItem]
	tree.set_column_expand(1, false)
	#tree.set_column_expand(0, false)
	for i in items.size():
		items[i].index = i
		var parent_index = get_parent_from_item(i)
		var item := tree.create_item(previous_tree_items[parent_index] if parent_index != -1 else null)
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
		print(config.get_value("display", "icon"))
		if ResourceLoader.exists(config.get_value("display", "icon")):
			item.set_cell_mode(0, TreeItem.CELL_MODE_CUSTOM)
			item.set_icon(0, load(config.get_value("display", "icon")))
			item.set_icon_modulate(0, Color("cdd6f4"))
		item.set_text(0, items[i].stripped_title)
		item.set_autowrap_mode(0, TextServer.AUTOWRAP_WORD_SMART)

		item.set_expand_right(0, true)
		#item.set_tooltip_text(0, "Type: %s" % config.get_value("display", "display_name"))
		previous_tree_items.append(item)

		print(items[i].title, ": ", get_parent_from_item(i))
		print(items[i].indents)
		var block_inst = (load(config.get_value("logic", "scene")) as PackedScene).instantiate()
		block_inst.name = items[i].title
		items[i].display_node = block_inst
		if get_parent_from_item(i) != -1:
			items[get_parent_from_item(i)].display_node.get_node(^"%ChildContainer").add_child(block_inst, true)
		else:
			%BlockDisplay.add_child(block_inst, true)
		for block: Block in block_inst.find_children("*", "Block"):
			block.args = items[i]
		block_inst.propagate_call("_update_block")

	tree_items = previous_tree_items.duplicate()



func get_parent_from_item(idx: int) -> int:
	var back_idx := 0
	while back_idx <= idx:
		#item[idx].indents <= item[back_idx].indents
		if items[idx].indents > items[idx - back_idx].indents:
			return idx - back_idx
		back_idx += 1
	return -1

func _on_tree_item_selected() -> void:
	curr_item = tree_items.find(tree.get_selected())
	print("new item selected, with an index of %d" % curr_item)

	for i in %PropertyList.get_children():
		i.reparent(self)
		i.queue_free()
	var config = FileManager.get_block_config(FileManager.block_types[items[curr_item].type])
	%TypeLabel.text = config.get_value("display", "display_name")
	%TypeIcon.texture = load(config.get_value("display", "icon"))
	var current_dict = items[curr_item]

	if config.has_section("properties"): for i in config.get_section_keys("properties"):
		var usage_tags = config.get_value("usage", i, "none").replace(" ", "").split(",")
		for tag in usage_tags:
			if FileManager.usage_types.has(tag):
				var inst := (FileManager.usage_types[tag] as PackedScene).instantiate() as PropertyBlock
				%PropertyList.add_child(inst)
				inst.name = i.to_pascal_case()
				if inst.has_node("%PropertyName"): inst.get_node("%PropertyName").text = i.replace("_", " ")
				inst.index = curr_item
				inst.responsible_property = i
				print(i, "'s value: ", current_dict.get(i))
				inst.display_value.call_deferred(current_dict.get_or_add(i, config.get_value("properties", i)))
				break

func _on_tree_item_edited() -> void:
	var curr_item = tree.get_edited()
	var curr_column = tree.get_edited_column()
	var config = FileManager.get_block_config(FileManager.block_types[items[tree_items.find(curr_item)].type])
	var curr_property: String
	print("edited item: ", curr_item.get_text(0), "; with index: ", tree_items.find(curr_item))
	print("edited item type: ", items[tree_items.find(curr_item)].type)
	if config.has_section("properties"): for i in config.get_section_keys("properties"):
		var usage_tags = config.get_value("usage", i, "none").replace(" ", "").split(",")
		for tag in usage_tags:
			if tag == "title_checkbox":
				curr_property = i
				break
	if curr_property and curr_item.get_cell_mode(curr_column) == TreeItem.CELL_MODE_CHECK:
		PropertyBus.property_changed.emit.call_deferred(
			tree_items.find(curr_item),
			curr_property,
			curr_item.is_checked(curr_column)
		)

func _on_property_changed(item: int, property: StringName, value: Variant) -> void:
	items[item][property] = value
	var config = FileManager.get_block_config(FileManager.block_types[items[item].type])
	var usage_tags = config.get_value("usage", property, "none").replace(" ", "").split(",")
	if "title_checkbox" in usage_tags:
		tree_items[item].set_checked(1, value)
	#if "tree_bg_color" in usage_tags:
		#tree_items[item].call_recursive("set_custom_bg_color", 0, Color(value).lerp(Color("#1e2030"), 0.8))
	if item == curr_item:
		var filtered_nodes = %PropertyList.get_children().filter(func(i: Node): return i.responsible_property == property)
		filtered_nodes[0].display_value(value)

func _on_property_search_text_changed(new_text: String) -> void:
	for i in %PropertyList.get_children():
		if new_text.is_empty():
			i.show()
		elif i is PropertyBlock:
			var similar_value = max((i.get_node(^"%PropertyName") as Label).text.similarity(new_text), i.responsible_property.similarity(new_text))
			i.visible = similar_value > 0.4

func _on_new_block_pressed() -> void:
	curr_new_block_window = MENU_NEW_BLOCK.instantiate()
	add_child(curr_new_block_window)
	curr_new_block_window.block_create_pressed.connect(create_block)

func create_block(type: String, to_item: TreeItem = null) -> void:
	var config = FileManager.get_block_config(FileManager.block_types[type])
	var parsed = LineParser.parse_line("[{Type}] New {Display Name}".format({"Type": type, "Display Name": config.get_value("display", "display_name")}))
	if to_item:
		tree.create_item(to_item)
	else:
		if tree.get_selected():
			pass
