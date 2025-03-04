extends Tree

func _get_drag_data(at_position: Vector2) -> Variant:
	return get_item_at_position(at_position)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if !data is TreeItem: return false
	drop_mode_flags = DROP_MODE_INBETWEEN | DROP_MODE_ON_ITEM
	var drop = get_drop_section_at_position(at_position)
	var on_item = get_item_at_position(at_position)
	match drop:
		-100:
			return false
		0:
			var item_dict = Main.node.items[Main.node.tree_items.find(on_item)]
			var config = FileManager.get_block_config(FileManager.block_types[item_dict.type])
			return config.get_value("logic", "can_have_children", false)
		-1:
			return on_item != get_root()
		1:
			return true
	return false
