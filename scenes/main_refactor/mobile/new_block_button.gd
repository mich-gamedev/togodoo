extends Button



@onready var tree: BlockTree = %Tree
@onready var create_new_block := %CreateNewBlock

func _ready() -> void:
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)
	create_new_block.block_selected.connect(tree.add_block_to_selected)
	pressed.connect(%"Tree Panel".hide)
	

var twn: Tween

func _mouse_entered() -> void:
	if TreeManager.items.is_empty(): return
	var idx = tree.tree_items.find_key(tree.get_selected())
	idx = idx if idx != null else TreeManager.get_root()
	var item = tree.tree_items[TreeManager.get_valid_parent(idx)]
	if item.is_selected(0): return
	if twn: twn.kill()
	twn = create_tween()
	twn.tween_method(
		func(clr): item.set_custom_bg_color(0, clr),
		Color("#1e2030"), Color("#24273a"),
		0.2
	)

func _mouse_exited() -> void:
	if TreeManager.items.is_empty(): return
	var idx = tree.tree_items.find_key(tree.get_selected())
	idx = idx if idx != null else TreeManager.get_root()
	if twn: twn.kill()
	tree.tree_items[TreeManager.get_valid_parent(idx)].clear_custom_bg_color(0)
