extends VBoxContainer

@onready var block: Block = $Block

func _update_block() -> void:
	for i in get_children():
		if i != block:
			i.queue_free()
	#TODO: finish adding blocks
	
	
