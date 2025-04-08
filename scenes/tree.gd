extends Tree


func _get_drag_data(at_position: Vector2) -> Variant:
	return get_item_at_position(at_position)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if !data is TreeItem: return false
	if data == get_root(): return false
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

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is TreeItem:
		var drop = get_drop_section_at_position(at_position)
		var to_item = get_item_at_position(at_position)
		var prev_index = Main.node.tree_items.find(data)
		var dict = Main.node.items[prev_index]
		match drop:
			-1:
				var new_index = Main.node.tree_items.find(to_item)
				data.move_before(to_item)
				Main.node.tree_items.remove_at(prev_index)
				Main.node.tree_items.insert(new_index, data)


				Main.node.items.remove_at(prev_index)
				Main.node.items.insert(new_index, dict)
				dict.index = new_index
				var parent = data
				dict.indents = 0
				while parent != get_root():
					parent = parent.get_parent()
					dict.indents += 1
			0:
				(data.get_parent() as TreeItem).remove_child(data)
				to_item.add_child(data)
				Main.node.tree_items.remove_at(prev_index)
				Main.node.items.remove_at(prev_index)
				var i: int
				var current := get_root()
				while current != data:
					current = current.get_next_in_tree()
					i += 1
				Main.node.tree_items.insert(i, data)

				Main.node.items.insert(i, dict)
				dict.index = i
				var parent = data
				dict.indents = 0
				while parent != get_root():
					parent = parent.get_parent()
					dict.indents += 1
			1:
				var new_index = Main.node.tree_items.find(to_item) + 1
				data.move_after(to_item)
				Main.node.tree_items.remove_at(prev_index)
				Main.node.tree_items.insert(new_index, data)


				Main.node.items.remove_at(prev_index)
				Main.node.items.insert(new_index, dict)
				dict.index = new_index
				var parent = data
				dict.indents = 0
				while parent != get_root():
					parent = parent.get_parent()
					dict.indents += 1

		var node := dict.display_node as Node
		var parent_index = Main.node.tree_items.find(data.get_parent())
		var parent_node := Main.node.items[parent_index].display_node.get_node(^"%ChildContainer") as Node
		node.reparent(parent_node, false)
		parent_node.move_child(node, data.get_index())
