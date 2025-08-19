extends Button

const DIALOG_DELETE_BLOCK = preload("uid://dwj50drmgm32x")

@onready var tree: BlockTree = %Tree

func _pressed() -> void:
	var inst = DIALOG_DELETE_BLOCK.instantiate()
	add_child(inst)
	inst.get_node("%Accept").pressed.connect(tree.destroy_selected)
