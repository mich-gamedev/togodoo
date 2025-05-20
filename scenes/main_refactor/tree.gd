class_name BlockTree extends Tree

var tree_items: Dictionary[int, TreeItem]

signal block_selected(idx: int)

var last_selected: TreeItem

func _ready() -> void:
	set_column_expand(1, false)
	TreeManager.signals.block_added.connect(_block_added)
	TreeManager.signals.pre_block_removed.connect(_block_removed)
	TreeManager.signals.block_moved.connect(_block_moved)
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

func add_block_to_selected(type: String) -> void:
	TreeManager.create_default_block(
		type,
		TreeManager.get_valid_parent(tree_items.find_key(get_selected()))
	)

func destroy_selected() -> void:
	TreeManager.remove_block(tree_items.find_key(get_selected()))

func _item_edited() -> void:
	TreeManager.set_property(tree_items.find_key(get_selected()), "title", get_selected().get_text(0))

func _get_drag_data(at_position: Vector2) -> Variant:
	return get_item_at_position(get_local_mouse_position())

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if !(data is TreeItem): return false
	drop_mode_flags = DROP_MODE_INBETWEEN
	return !get_drop_section_at_position(at_position) == -100

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is TreeItem:
		var section = get_drop_section_at_position(at_position)
		TreeManager.move_block(tree_items.find_key(data), tree_items.find_key(get_item_at_position(at_position)) + section)

func _block_moved(dict: Dictionary, idx: int, from: int, to: int) -> void:
	tree_items[from].remove_child(tree_items[idx])
	tree_items[to].add_child(tree_items[idx])
