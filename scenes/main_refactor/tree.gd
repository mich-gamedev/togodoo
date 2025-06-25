class_name BlockTree extends Tree

var tree_items: Dictionary[int, TreeItem]

signal block_selected(idx: int)

var last_selected: TreeItem

@onready var scroll: SmoothScrollContainer = $".."

func _ready() -> void:
	set_column_expand(1, false)
	#TreeManager.signals.block_added.connect(_block_added)
	#TreeManager.signals.pre_block_removed.connect(_block_removed)
	#TreeManager.signals.block_moved.connect(_block_moved)
	TreeManager.signals.tree_changed.connect(reset_tree)
	PropertyBus.property_changed.connect(_property_changed)
	item_selected.connect(_item_selected)
	item_edited.connect(_item_edited)


func _block_added(dict: Dictionary, idx: int) -> void:
	var tree_item: TreeItem
	if dict.parent == -1:
		tree_item = create_item()
	else:
		tree_item = create_item(tree_items[dict.parent])
	tree_item.set_text(0, dict.stripped_title)
	tree_item.set_icon(0, load(FileManager.get_block_config_by_type(dict.type).get_value("display", "icon")))
	tree_item.set_icon_modulate(0, Color("cdd6f4"))
	tree_item.set_autowrap_mode(0, TextServer.AUTOWRAP_WORD_SMART)
	tree_items[idx] = tree_item
	if !get_selected(): set_selected(tree_item, 0)

	var cfg = FileManager.get_block_config_by_type(dict.type)
	for i in cfg.get_section_keys("properties"):
		var value = TreeManager.get_property(idx, i)
		if String(cfg.get_value("usage", i)).contains("tree_bg_color") and value != cfg.get_value("properties", i):
			tree_item.set_icon_modulate(0, value)

func _block_removed(dict: Dictionary, idx: int) -> void:
	var item : TreeItem = tree_items[idx]
	tree_items.erase(idx)
	if is_instance_valid(item): item.free()

func _item_selected() -> void:
	block_selected.emit(tree_items.find_key(get_selected()))
	if last_selected: last_selected.set_editable(0, false)
	get_selected().set_editable.call_deferred(0, true)
	last_selected = get_selected()

func _property_changed(idx: int, property: StringName, value: Variant, reset_property_list: bool) -> void:
	var cfg = FileManager.get_block_config_by_type(TreeManager.items[idx].type)
	if cfg.has_section_key("usage", property) and String(cfg.get_value("usage", property)).contains("tree_bg_color") and value != cfg.get_value("properties", property):
		tree_items[idx].set_icon_modulate(0, value)

func add_block_to_selected(type: String, select_new: bool = true) -> void:
	TreeManager.create_default_block(
		type,
		TreeManager.get_valid_parent(tree_items.find_key(get_selected()))
	)

func destroy_selected() -> void:
	TreeManager.remove_block(tree_items.find_key(get_selected()))

func _item_edited() -> void:
	TreeManager.set_property(tree_items.find_key(get_selected()), "title", get_selected().get_text(0))

func _get_drag_data(at_position: Vector2) -> Variant:
	var item = get_item_at_position(at_position)
	if item == get_root(): return null
	if get_drop_section_at_position(at_position) == -100: return null
	return get_item_at_position(at_position)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if !(data is TreeItem): return false
	if !tree_items.values().has(data): return false
	drop_mode_flags = DROP_MODE_INBETWEEN | DROP_MODE_ON_ITEM
	var section = get_drop_section_at_position(at_position)
	match section:
		-1: return get_root() != data
		0:  return TreeManager.get_config(tree_items.find_key(get_item_at_position(at_position))).get_value("logic", "can_have_children", false)
		1:  return true
	return false # won't be reached

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is TreeItem:
		var section = get_drop_section_at_position(at_position)
		match section:
			-1, 1: # between
				var to_item = get_item_at_position(at_position)
				var to_idx = tree_items.find_key(to_item)
				var idx  = tree_items.find_key(data)
				var parent = TreeManager.get_parent(to_idx)
				parent = parent if !TreeManager.get_config(to_idx).get_value("logic", "can_have_children", false) else to_idx
				var at = TreeManager.get_children(parent).find(to_idx) + (0 if section == -1 else 1)#section
				print("PRE MOVE CHILDREN:", TreeManager.get_children(parent).map(func(i): return TreeManager.get_title(i)))
				print("PLACING: %s, %d, at = %d" % [TreeManager.get_title(to_idx), section, at])
				TreeManager.move_block(idx, parent, at)
			0: # onto
				var to_item = get_item_at_position(at_position)
				var to_idx = tree_items.find_key(to_item)
				var idx  = tree_items.find_key(data)
				TreeManager.move_block(idx, to_idx)

func _block_moved(dict: Dictionary, idx: int, from: int, to: int, at: int) -> void:
	tree_items[from].remove_child(tree_items[idx])
	tree_items[to].add_child(tree_items[idx])
	print("TREE RECIEVED BLOCK MOVE:", at)
	if at != -1:
		tree_items[idx].move_after(tree_items[TreeManager.get_children(to)[at - 1]])

func reset_tree(keep_selected: bool = true) -> void:
	#var selected : int = tree_items.find_key(get_selected()) if tree_items.find_key(get_selected()) else -1
	if get_root(): get_root().free()
	tree_items = {}

	for i in TreeManager.get_sorted_blocks():
		var dict = TreeManager.items[i]
		var tree_item: TreeItem
		if dict.parent == -1:
			tree_item = create_item()
		else:
			tree_item = create_item(tree_items[dict.parent])
		tree_item.set_text(0, dict.stripped_title)
		tree_item.set_icon(0, load(FileManager.get_block_config_by_type(dict.type).get_value("display", "icon")))
		tree_item.set_icon_modulate(0, Color("cdd6f4"))
		tree_item.set_autowrap_mode(0, TextServer.AUTOWRAP_WORD_SMART)
		tree_items[i] = tree_item
	#if keep_selected and tree_items.has(selected): tree_items[selected].select(0)

func scroll_to(item: int) -> void:
	tree_items[item].select(0)
	scroll.scroll_y_to(get_item_area_rect(tree_items[item]).position.y)
