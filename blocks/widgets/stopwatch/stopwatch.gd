extends HFlowContainer

@onready var block: Block = $Block

func _update_block() -> void:
	if block.get_arg()
