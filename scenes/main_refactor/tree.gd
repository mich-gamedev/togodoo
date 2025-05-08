extends Tree

#region NODES

var tree_items: Dictionary[int, TreeItem]

func _ready() -> void:
	set_column_expand(1, false)
	TreeManager.signals.block_added.connect(_block_added)

func _block_added(dict: Dictionary, idx: int) -> void:
	var tree_item: TreeItem
	if dict.parent == -1:
		tree_item = create_item()
	else:
		tree_item = create_item(tree_items[dict.parent])
	tree_item.set_text(0, dict.stripped_title)
	tree_items[idx] = tree_item
