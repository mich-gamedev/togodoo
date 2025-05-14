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
	var idx = tree.tree_items.find_key(tree.get_selected())
	if twn: twn.kill()
	twn = create_tween()
	twn.tween_method(
		func(clr): tree.tree_items[TreeManager.get_valid_parent(idx)].set_custom_bg_color(0, clr),
		Color("#1e2030"), Color("#363a4f"),
		0.2
	)

func _mouse_exited() -> void:
	var idx = tree.tree_items.find_key(tree.get_selected())
	if twn: twn.kill()
	tree.tree_items[TreeManager.get_valid_parent(idx)].clear_custom_bg_color(0)
