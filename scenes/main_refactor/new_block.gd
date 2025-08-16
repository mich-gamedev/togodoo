extends Button

const MENU_NEW_BLOCK = preload("res://scenes/main_refactor/create_new_block.tscn")

@onready var tree: BlockTree = %Tree

func _ready() -> void:
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)

func _pressed() -> void:
	var inst = MENU_NEW_BLOCK.instantiate()
	add_child(inst)
	inst.block_selected.connect(tree.add_block_to_selected)

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
