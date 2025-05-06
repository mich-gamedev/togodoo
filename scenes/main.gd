class_name Main extends Control

static var node: Main

@onready var tree: Tree = %Tree

var tree_items : Array[TreeItem]
var items : Array[Dictionary]

var curr_item: int

const MENU_NEW_BLOCK = preload("res://scenes/menu_new_block.tscn")
const DIALOG_DELETE_BLOCK = preload("res://scenes/dialog_delete_block.tscn")

var curr_new_block_window: Window


func _ready() -> void: #TODO: replace with selection later
	get_tree().root.close_requested.connect(_close_requested)
	node = self
	PropertyBus.save_requested.connect(_on_save_requested)
	PropertyBus.favorite_block_changed.connect(change_favorite_list)
	Settings.find_mods()
	var recent_projects := Array(Settings.get_setting("vanilla", "editor/recent_projects"))
	recent_projects.push_back(FileManager.file_path)
	Settings.set_setting(
		"vanilla",
		"editor/recent_projects",
		recent_projects
	)
	var file = FileAccess.open(FileManager.file_path, FileAccess.READ)
	print(error_string(FileAccess.get_open_error()))
	PropertyBus.property_changed.connect(_on_property_changed)

	get_window().title = "Togodoo - %s" % FileManager.file_path.split("/")[-1]

	while file.get_position() < file.get_length():
		var line = file.get_line()
		var parsed = LineParser.parse_line(line)
		if !parsed.is_empty():
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
	change_favorite_list(Settings.get_setting("vanilla", "editor/favorite_blocks"))

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
				inst.default_value = config.get_value("properties", i)
				print(i, "'s value: ", current_dict.get(i))
				inst.display_value.call_deferred(current_dict.get_or_add(i, config.get_value("properties", i)))
				inst.tooltip_text = config.get_value("hints", i, "")
				break

	var seperator = FileManager.usage_types["property_seperator"].instantiate() as PropertyBlock
	%PropertyList.add_child(seperator)
	seperator.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_SHRINK_END

	var title_inst := FileManager.usage_types["property_multiline"].instantiate() as PropertyBlock
	%PropertyList.add_child(title_inst)
	title_inst.name = "Title"
	if title_inst.has_node("%PropertyName"): title_inst.get_node("%PropertyName").text = "title"
	title_inst.index = curr_item
	title_inst.responsible_property = "title"
	title_inst.property_usage_tags = ["property_multiline"]
	title_inst.default_value = ""
	title_inst.display_value.call_deferred(current_dict.get_or_add("title", config.get_value("display", "display_name")))

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
		curr_item.set_text(0, LineParser.format_title(curr_item.get_text(0)))
		PropertyBus.property_changed.emit.call_deferred(
			tree_items.find(curr_item),
			"title",
			curr_item.get_text(0),
			true
		)
		var regex = RegEx.new()
		regex.compile("\\[.*?\\]")
		curr_item.set_text(0, regex.sub(curr_item.get_text(0), "", true))

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
	if !reset_property_list and property == "title":
		var regex = RegEx.new()
		regex.compile("\\[.*?\\]")
		tree_items[item].set_text(0, regex.sub(value, "", true))


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
	var i: int = 0
	var current := tree.get_root()
	while current != new_item:
		current = current.get_next_in_tree()
		i += 1
	for block in %FavoriteBlocks.get_children():
		block.disabled = false
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
		block_inst.get_parent().move_child(block_inst, item.get_index())
	else:
		%BlockDisplay.add_child(block_inst, true)
	for block: Block in block_inst.find_children("*", "Block"):
		block.args = info
	block_inst.propagate_call("_update_block")

var tree_tween: Tween
var last_hovered_item: TreeItem

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"rename", false, true):
		tree.edit_selected()
	elif event.is_action_pressed(&"save", false, true):
		PropertyBus.save_requested.emit("")
		get_window().set_input_as_handled()
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
	elif event.is_action_pressed(&"delete_skip_dialog", false, true):
		remove_block(curr_item)
	elif event.is_action_pressed(&"ui_text_delete", false, true):
		_on_destroy_block_pressed()
	elif event.is_action_pressed(&"ui_copy", false, true):
		var dict = items[curr_item]; dict.erase("display_node")
		DisplayServer.clipboard_set(var_to_str(dict))
	elif event.is_action_pressed(&"ui_paste", false, true):
		var parent_config = FileManager.get_block_config(FileManager.block_types[items[curr_item].type])
		var to_item: TreeItem
		if parent_config.get_value("logic", "can_have_children", false):
			to_item = tree_items[curr_item]
		else:
			to_item = tree_items[curr_item].get_parent()

		var dict = str_to_var(DisplayServer.clipboard_get())
		if dict:
			var new_item = to_item.create_child()
			var idx := 0
			var current_block = tree.get_root()
			while current_block != new_item:
				current_block = current_block.get_next_in_tree()
				idx += 1
			tree_items.insert(idx, new_item)
			items.insert(idx, dict)
			setup_item(dict, new_item)
	elif event.is_action_pressed(&"duplicate", false, true):
		var parent_config = FileManager.get_block_config(FileManager.block_types[items[curr_item].type])
		var to_item: TreeItem
		if parent_config.get_value("logic", "can_have_children", false):
			to_item = tree_items[curr_item]
		else:
			to_item = tree_items[curr_item].get_parent()
		var new_item = to_item.create_child(tree_items[curr_item].get_index() + 1)
		var idx := 0
		var current_block = tree.get_root()
		while current_block != new_item:
			current_block = current_block.get_next_in_tree()
			idx += 1
		tree_items.insert(idx, new_item)
		items.insert(idx, items[curr_item].duplicate())
		setup_item(items[idx], new_item)
	elif event.is_action_pressed(&"new_block", false, true):
		_on_new_block_pressed()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode in range(KEY_1, KEY_9) and event.pressed:
			var num = event.keycode - KEY_1
			var favs : Array = Settings.get_setting("vanilla", "editor/favorite_blocks")
			if favs.size() > num:
				create_default_block(favs[num])
				get_viewport().set_input_as_handled()

func _on_save_requested(path: String) -> void:
	Settings.save_config("vanilla")
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
	FileManager.file_path = path
	var file = FileAccess.open(path, FileAccess.WRITE)
	for i in items:
		file.store_line(LineParser.parse_dict(i))
	%SaveIndicator.modulate.a = 1.0
	%SaveIndicator.text = "Saving..."
	var tween := create_tween()
	tween.tween_property(%SaveIndicator, "modulate:a", 0.0, 3.0)
	PropertyBus.save_successful.emit()
	get_window().title = "Togodoo - %s" % FileManager.file_path.split("/")[-1]

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
	new_block_tween.tween_method(func(v): if is_instance_valid(to_item): to_item.set_custom_bg_color(0, v), Color("#24273a00"), Color("#24273aFF"), 0.2)

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

func _on_destroy_block_pressed() -> void:
	var dialog = DIALOG_DELETE_BLOCK.instantiate()
	add_child(dialog)
	dialog.show()
	dialog.get_node(^"%Label").text %= items[curr_item].title
	(dialog.get_node(^"%Accept") as Button).pressed.connect(remove_block.bind(curr_item))

func remove_block(idx: int) -> void:
	items[idx].display_node.queue_free()
	items.remove_at(idx)
	if idx == curr_item:
		%TypeIcon.texture = load("res://resources/themes/x.svg")
		%TypeLabel.text = "Nothing Selected"
		for i in %PropertyList.get_children():
			i.queue_free()
		curr_item = 0
	tree_items[idx].free()
	tree_items = tree_items.filter(func(a): return is_instance_valid(a))

func change_favorite_list(array: Array) -> void:
	for i in %FavoriteBlocks.get_children(): i.queue_free()
	for i in array.size():
		var inst := Button.new()
		inst.expand_icon = true
		inst.custom_minimum_size.x = 16
		inst.icon = load(FileManager.get_block_config(FileManager.block_types[array[i]]).get_value("display", "icon"))
		inst.tooltip_text = "%s (%d)" % [array[i], i+1]
		inst.disabled = !can_block_spawn(array[i])
		%FavoriteBlocks.add_child(inst)
		inst.pressed.connect(create_default_block.bind(array[i]))

const BLOCK_CONTEXT_MENU = preload("res://scenes/block_context_menu.tscn")

func _on_tree_gui_input(event: InputEvent) -> void:
	if !%Tree.get_item_at_position(%Tree.get_local_mouse_position()): return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and !event.pressed:
			var inst = BLOCK_CONTEXT_MENU.instantiate()
			add_child(inst)
			inst.position = DisplayServer.mouse_get_position()
			inst.visibility_changed.connect(inst.queue_free)
			inst.index_pressed.connect(_on_block_context_pressed.bind(inst))

func _on_block_context_pressed(id: int, menu: PopupMenu) -> void:
	match menu.get_item_text(id):
		"add child block":
			_on_new_block_pressed()
		"cut       (Ctrl + X)":
			var dict = items[curr_item]; dict.erase("display_node")
			DisplayServer.clipboard_set(var_to_str(dict))
			remove_block(curr_item)
		"copy      (Ctrl + C)":
			var dict = items[curr_item]; dict.erase("display_node")
			DisplayServer.clipboard_set(var_to_str(dict))
		"paste     (Ctrl + V)":
			var parent_config = FileManager.get_block_config(FileManager.block_types[items[curr_item].type])
			var to_item: TreeItem
			if parent_config.get_value("logic", "can_have_children", false):
				to_item = tree_items[curr_item]
			else:
				to_item = tree_items[curr_item].get_parent()

			var dict = str_to_var(DisplayServer.clipboard_get())
			if dict:
				var new_item = to_item.create_child()
				var idx := 0
				var current_block = tree.get_root()
				while current_block != new_item:
					current_block = current_block.get_next_in_tree()
					idx += 1
				tree_items.insert(idx, new_item)
				items.insert(idx, dict)
				setup_item(dict, new_item)

static func can_block_spawn(type: String) -> bool:
	if !node.items.is_empty(): return true
	return FileManager.get_block_config(FileManager.block_types[type]).get_value("logic", "can_have_children", false)

const UNSAVED = preload("res://scenes/unsaved.tscn")
func _close_requested() -> void:
	add_child(UNSAVED.instantiate())
