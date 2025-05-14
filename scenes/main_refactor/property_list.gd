extends VBoxContainer

@onready var tree: BlockTree = %Tree

func _ready() -> void:
	tree.block_selected.connect(_block_selected)

func _block_selected(idx: int) -> void:
	for i in get_children(): i.queue_free()
	var stack_items = TreeManager.items
	var cfg : ConfigFile = FileManager.get_block_config_by_type(TreeManager.items[idx].type)
	for key in cfg.get_section_keys("properties"):
		var tags = String(cfg.get_value("usage", key, "none")).split(",")
		for tag in tags:
			if FileManager.usage_types.has(tag):
				var inst := FileManager.usage_types[tag].instantiate() as PropertyBlock
				add_child(inst)
				inst.name = key.to_pascal_case()
				if inst.has_node("%PropertyName"): inst.get_node("%PropertyName").text = key.replace("_", " ")
				inst.index = idx
				inst.responsible_property = key
				inst.property_usage_tags = tags
				inst.default_value = cfg.get_value("properties", key)
				inst.display_value.call_deferred(TreeManager.get_property(idx, key))
				inst.tooltip_text = cfg.get_value("hints", key, "")
