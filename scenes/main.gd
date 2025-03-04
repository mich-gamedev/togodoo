class_name Main extends Control

static var node: Main

@onready var tree: Tree = %Tree

var tree_items : Array[TreeItem]
var items : Array[Dictionary]

var curr_item: int

const MENU_NEW_BLOCK = preload("res://scenes/menu_new_block.tscn")

var curr_new_block_window: Window


func _ready() -> void: #TODO: replace with selection later
	node = self
	PropertyBus.save_requested.connect(_on_save_requested)
	FileManager.load_mods()
	var file = FileAccess.open(FileManager.file_path, FileAccess.READ)
	PropertyBus.property_changed.connect(_on_property_changed)

	while file.get_position() < file.get_length():
		var line = file.get_line()
		var parsed = LineParser.parse_line(line)
		items.append(parsed)
	tree.set_column_expand(1, false)
	#tree.set_column_expand(0, false)
	for i in items.size():
		items[i].index = i
		var parent_index = get_parent_from_item(i)
		var item := tree.create_item(tree_items[parent_index] if parent_index != -1 else null)
		#item.set_expand_right(0, false)
		tree_items.append(item)
		setup_item(items[i], item)
		#var config := FileManager.get_block_config(FileManager.block_types[items[i].type])
		#if config.has_section("usage"): for arg in config.get_section_keys("usage"):
			#if String(config.get_value("usage", arg)).replace(" ", "").split(",").has("title_checkbox"):
				#item.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
				#item.set_editable(1, true)
				#item.set_checked(1, items[i].get(arg))
				#item.set_expand_right(1, false)
				#item.set_icon_max_width(1, 16)
				#break
		#print(config.get_value("display", "icon"))
		#if ResourceLoader.exists(config.get_value("display", "icon")):
			#item.set_cell_mode(0, TreeItem.CELL_MODE_CUSTOM)
			#item.set_icon(0, load(config.get_value("display", "icon")))
			#item.set_icon_modulate(0, Color("cdd6f4"))
		#item.set_text(0, items[i].stripped_title)
		#item.set_autowrap_mode(0, TextServer.AUTOWRAP_WORD_SMART)
#
		#item.set_expand_right(0, true)
		##item.set_tooltip_text(0, "Type: %s" % config.get_value("display", "display_name"))
		#previous_tree_items.append(item)
#
		#print(items[i].title, ": ", get_parent_from_item(i))
		#print(items[i].indents)
		#var block_inst = (load(config.get_value("logic", "scene")) as PackedScene).instantiate()
		#block_inst.name = items[i].title
		#items[i].display_node = block_inst
		#if get_parent_from_item(i) != -1:
			#items[get_parent_from_item(i)].display_node.get_node(^"%ChildContainer").add_child(block_inst, true)
		#else:
			#%BlockDisplay.add_child(block_inst, true)
		#for block: Block in block_inst.find_children("*", "Block"):
			#block.args = items[i]
		#block_inst.propagate_call("_update_block")




func get_parent_from_item(idx: int) -> int:
	var back_idx := 0
	while back_idx <= idx:
		#item[idx].indents <= item[back_idx].indents
		if items[idx].indents > items[idx - back_idx].indents:
			return idx - back_idx
		back_idx += 1
	return -1

func _on_tree_item_selected() -> void:
	tree_items[curr_item].set_editable(0, false)
	curr_item = tree_items.find(tree.get_selected())
	print("new item selected, with an index of %d" % curr_item)

	for i in %PropertyList.get_children():
		i.reparent(self)
		i.queue_free()
	var config = FileManager.get_block_config(FileManager.block_types[items[curr_item].type])
	%TypeLabel.text = config.get_value("display", "display_name")
	%TypeIcon.texture = load(config.get_value("display", "icon"))
	var current_dict = items[curr_item]

	tree_items[curr_item].set_editable.call_deferred(0, true)

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
				inst.property_usage_tags = usage_tags
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
			curr_item.is_checked(curr_column),
			true
		)
	if curr_column == 0:
		PropertyBus.property_changed.emit.call_deferred(
			tree_items.find(curr_item),
			"title",
			curr_item.get_text(0),
			true
		)

func _on_property_changed(item: int, property: StringName, value: Variant, reset_property_list := true) -> void:
	items[item][property] = value
	var config = FileManager.get_block_config(FileManager.block_types[items[item].type])
	var usage_tags = config.get_value("usage", property, "none").replace(" ", "").split(",")
	if "title_checkbox" in usage_tags:
		tree_items[item].set_checked(1, value)
	#if "tree_bg_color" in usage_tags:
		#tree_items[item].call_recursive("set_custom_bg_color", 0, Color(value).lerp(Color("#1e2030"), 0.8))
	if reset_property_list and item == curr_item:
		var filtered_nodes = %PropertyList.get_children().filter(func(i: Node): return i.responsible_property == property)
		if !filtered_nodes.is_empty(): filtered_nodes[0].display_value(value)

func _on_property_search_text_changed(new_text: String) -> void:
	for i in %PropertyList.get_children():
		if new_text.is_empty():
			i.show()
		elif i is PropertyBlock:
			var similar_value = max((i.get_node(^"%PropertyName") as Label).text.similarity(new_text), i.responsible_property.similarity(new_text))
			i.visible = similar_value > 0.4

func _on_new_block_pressed() -> void:
	curr_new_block_window = MENU_NEW_BLOCK.instantiate()
	curr_new_block_window.show()
	add_child(curr_new_block_window)
	curr_new_block_window.block_create_pressed.connect(create_default_block)

func create_default_block(type: String, to_item: TreeItem = null) -> void:
	var config = FileManager.get_block_config(FileManager.block_types[type])
	var parsed = LineParser.parse_line("[{Type}] New {Display Name}".format({"Type": type, "Display Name": config.get_value("display", "display_name")}))
	if !to_item:
		if curr_item and tree_items.size() > curr_item:
			var parent_config = FileManager.get_block_config(FileManager.block_types[items[curr_item].type])
			if parent_config.get_value("logic", "can_have_children", false):
				to_item = tree_items[curr_item]
			else:
				to_item = tree_items[curr_item].get_parent()
		else: to_item = tree.get_root()
	var new_item = tree.create_item(to_item)
	var i: int
	var current := tree.get_root()
	while current != new_item:
		current = current.get_next_in_tree()
		i += 1
	parsed.index = i
	tree_items.insert(parsed.index, new_item)
	items.insert(parsed.index, parsed)
	print("items = ", items.map(func(a): return a.title))
	print("tree items = ", tree_items.map(func(a): return a.get_text(0)))
	print("parent's index = ", tree_items.find(to_item))
	print("child relative index = ", new_item.get_index())
	var last_parent_item: TreeItem = new_item
	while last_parent_item.get_parent():
		last_parent_item = last_parent_item.get_parent()
		parsed.indents += 1
	setup_item(parsed, new_item)
	tree.scroll_to_item(new_item)

func setup_item(info: Dictionary, item: TreeItem) -> void:
	var config := FileManager.get_block_config(FileManager.block_types[info.type])
	if config.has_section("usage"): for arg in config.get_section_keys("usage"):
		if String(config.get_value("usage", arg)).replace(" ", "").split(",").has("title_checkbox"):
			item.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
			item.set_editable(1, true)
			item.set_checked(1, info.get_or_add(arg, config.get_value("properties", arg)))
			item.set_expand_right(1, false)
			item.set_icon_max_width(1, 16)
			break
	print(config.get_value("display", "icon"))
	if ResourceLoader.exists(config.get_value("display", "icon")):
		item.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
		item.set_icon(0, load(config.get_value("display", "icon")))
		item.set_icon_modulate(0, Color("cdd6f4"))
		#item.set_editable(0, true)
	item.set_text(0, info.title)
	item.set_autowrap_mode(0, TextServer.AUTOWRAP_WORD_SMART)

	item.set_expand_right(0, true)
	item.set_tooltip_text(0, "Type: %s" % config.get_value("display", "display_name"))

	print(info.title, ": ", get_parent_from_item(info.index))
	print(info.indents)
	var block_inst = (load(config.get_value("logic", "scene")) as PackedScene).instantiate()
	block_inst.name = info.title
	info.display_node = block_inst
	if get_parent_from_item(info.index) != -1:
		items[get_parent_from_item(info.index)].display_node.get_node(^"%ChildContainer").add_child(block_inst, true)
	else:
		%BlockDisplay.add_child(block_inst, true)
	for block: Block in block_inst.find_children("*", "Block"):
		block.args = info
	block_inst.propagate_call("_update_block")

var tree_tween: Tween
var last_hovered_item: TreeItem

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"rename"):
		tree.edit_selected()
	elif event.is_action_pressed(&"save"):
		PropertyBus.save_requested.emit("")
	elif event is InputEventMouseMotion:
		var item = tree.get_item_at_position(tree.get_local_mouse_position())
		if item != last_hovered_item:
			if tree_tween:
				tree_tween.kill()
			for i in tree_items:
				i.set_custom_bg_color(0, Color("#363a4f00"))
			if get_viewport().gui_is_dragging(): return
			if item:
				tree_tween = create_tween()
				tree_tween.tween_method(func(a): item.set_custom_bg_color(0, a, true), Color("#a5adcb00"), Color("#a5adcbFF"), 0.15)
			last_hovered_item = item

func _on_save_requested(path: String) -> void:
	if path == "":
		if !FileManager.file_path.begins_with("res://"):
			path = FileManager.file_path
		else:
			var dialog = FileDialog.new()
			dialog.access = FileDialog.ACCESS_FILESYSTEM
			dialog.use_native_dialog = true
			dialog.add_filter("*.togodoo", "Togodoo Project")
			dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			dialog.current_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
			dialog.file_selected.connect(_dialog_accepted)
			add_child(dialog)
			dialog.show()
			return
	var file = FileAccess.open(path, FileAccess.WRITE)
	for i in items:
		file.store_line(LineParser.parse_dict(i))
	%SaveIndicator.modulate.a = 1.0
	%SaveIndicator.text = "Saving..."
	var tween := create_tween()
	tween.tween_property(%SaveIndicator, "modulate:a", 0.0, 3.0)

func _dialog_accepted(path: String) -> void:
	PropertyBus.save_requested.emit(path)

var new_block_tween: Tween

func _on_new_block_mouse_entered() -> void:
	if items.is_empty(): return
	var parent_config = FileManager.get_block_config(FileManager.block_types[items[curr_item].type])
	var to_item: TreeItem
	if parent_config.get_value("logic", "can_have_children", false):
		to_item = tree_items[curr_item]
	else:
		to_item = tree_items[curr_item].get_parent()
	if new_block_tween: new_block_tween.kill()
	new_block_tween = get_tree().create_tween().set_parallel()
	new_block_tween.tween_method(func(v): to_item.set_custom_bg_color(0, v), Color("#24273a00"), Color("#24273aFF"), 0.2)

func _on_new_block_mouse_exited() -> void:
	if items.is_empty(): return
	var parent_config = FileManager.get_block_config(FileManager.block_types[items[curr_item].type])
	var to_item: TreeItem
	if parent_config.get_value("logic", "can_have_children", false):
		to_item = tree_items[curr_item]
	else:
		to_item = tree_items[curr_item].get_parent()
	if new_block_tween: new_block_tween.kill()
	new_block_tween = get_tree().create_tween().set_parallel()
	new_block_tween.tween_method(func(v): to_item.set_custom_bg_color(0, v), Color("#24273aFF"), Color("#24273a00"), 0.2)
