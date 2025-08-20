extends VBoxContainer

@onready var block: Block = $Block

func _update_block() -> void:
	for i in get_children():
		if i != block:
			i.queue_free()

	var file = FileAccess.open(block.get_arg("project"), FileAccess.READ)
	var items: Array[Dictionary]
	while file.get_position() < file.get_length():
		items.append(LineParser.parse_line(file.get_line()))

	#var root_prefab : TreeItem = Main.node.tree_items[block.get_idx()]
	#TODO: finish block creation

	#for i in items.size():
		#
		##var tree_item = parent.create_child()
		##Main.node.setup_item(items[i], tree_item)
