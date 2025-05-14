class_name BlockTree extends Tree

var tree_items: Dictionary[int, TreeItem]

signal block_selected(idx: int)

func _ready() -> void:
	set_column_expand(1, false)
	TreeManager.signals.block_added.connect(_block_added)
	TreeManager.signals.pre_block_removed.connect(_block_removed)
	item_selected.connect(_item_selected)

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

func _block_removed(dict: Dictionary, idx: int) -> void:
	var item : TreeItem = tree_items[idx]
	tree_items.erase(idx)
	if is_instance_valid(item): item.free()

func _item_selected() -> void:
	block_selected.emit(tree_items.find_key(get_selected()))

func add_block_to_selected(type: String) -> void:
	TreeManager.create_default_block(
		type,
		TreeManager.get_valid_parent(tree_items.find_key(get_selected()))
	)

func destroy_selected() -> void:
	TreeManager.remove_block(tree_items.find_key(get_selected()))
