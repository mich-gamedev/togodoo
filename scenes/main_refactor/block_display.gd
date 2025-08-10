class_name BlockDisplay extends VBoxContainer

var blocks: Dictionary[int, Node]
static var headers: Dictionary[String, int]
static var node: BlockDisplay

@onready var tree: BlockTree = %Tree
@onready var scroll: SmoothScrollContainer = $"../../../VSplitContainer/Tree/MarginContainer2/VBoxContainer/SmoothScrollContainer"
@onready var block_hover_indicator: Panel = %BlockHoverIndicator

func _ready() -> void:
	TreeManager.signals.block_added.connect(_block_added)
	TreeManager.signals.pre_block_removed.connect(_block_removed)
	TreeManager.signals.block_moved.connect(_block_moved)
	node = self

func _block_added(dict: Dictionary, idx: int) -> void:
	var cfg = FileManager.get_block_config_by_type(dict.type)
	var inst : Control = load(cfg.get_value("logic", "scene")).instantiate()
	inst.name = String(dict.title).to_pascal_case()
	if inst.has_node(^"%HoverRect"):
		inst.get_node(^"%HoverRect").mouse_entered.connect(_mouse_entered.bind(idx))
		inst.get_node(^"%HoverRect").mouse_exited.connect(_mouse_exited.bind(idx))
		inst.get_node(^"%HoverRect").gui_input.connect(_display_input.bind(idx))
	else:
		inst.mouse_entered.connect(_mouse_entered.bind(idx))
		inst.mouse_exited.connect(_mouse_exited.bind(idx))
		inst.gui_input.connect(_display_input.bind(idx))
	blocks[idx] = inst
	if dict.parent == -1:
		add_child(inst)
	else:
		blocks[TreeManager.get_valid_parent(dict.parent)].get_node(^"%ChildContainer").add_child(inst)
	for block: Block in inst.find_children("*", "Block"):
		block.args = dict
	inst.propagate_call("_update_block")

func _block_removed(dict: Dictionary, idx: int) -> void:
	var block = blocks[idx]
	blocks.erase(idx)
	block.queue_free()

func _block_moved(_dict: Dictionary, idx: int, _from: int, to: int, at: int) -> void:
	blocks[idx].reparent(blocks[to].get_node(^"%ChildContainer"))
	blocks[to].get_node(^"%ChildContainer").move_child(blocks[idx], at)

var twn: Tween

func _mouse_entered(idx: int) -> void:
	#if twn: twn.kill()
	#twn = create_tween()
	#twn.tween_method(
		#func(clr): tree.tree_items[idx].set_custom_bg_color(0, clr, true),
		#Color("#1e2030"), Color("#363a4f"),
		#0.1
	#)
	block_hover_indicator.show()
	block_hover_indicator.modulate.a = 0
	if twn: twn.kill()
	twn = create_tween()
	twn.tween_property(block_hover_indicator, ^"modulate:a", 1, 0.1)
	var rect = tree.get_item_area_rect(tree.tree_items[idx])
	block_hover_indicator.position = rect.position
	block_hover_indicator.size = rect.size

func _mouse_exited(idx: int) -> void:
	block_hover_indicator.hide()

func _display_input(event: InputEvent, idx: int) -> void:
	if event is InputEventMouseButton: if event.button_index == MOUSE_BUTTON_LEFT:
		tree.set_selected(tree.tree_items[idx], 0)
		tree.grab_focus.call_deferred()

static func scroll_to_header(header: String) -> void:
	header = header.trim_prefix("#")
	if !header.is_valid_int(): return
	var to_int = header.to_int()
	for i in TreeManager.items:
		if i == to_int:
			node.scroll.scroll_y_to.call_deferred(node.blocks[i].position)
			node.tree.scroll_to.call_deferred(i)
