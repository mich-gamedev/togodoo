extends VBoxContainer

var blocks: Dictionary[int, Node]

func _ready() -> void:
	TreeManager.signals.block_added.connect(_block_added)

func _block_added(dict: Dictionary, idx: int) -> void:
	var cfg = FileManager.get_block_config_by_type(dict.type)
	var inst : Node = load(cfg.get_value("logic", "scene")).instantiate()
	inst.name = String(dict.title).to_pascal_case()
	blocks[idx] = inst
	if dict.parent == -1:
		add_child(inst)
	else:
		blocks[TreeManager.get_valid_parent(dict.parent)].get_node(^"%ChildContainer").add_child(inst)
	for block: Block in inst.find_children("*", "Block"):
		block.args = dict
	inst.propagate_call("_update_block")
