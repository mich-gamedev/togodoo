extends RichTextLabel

@onready var block: Block = $Block

func _update_blocks() -> void:
	text = block.get_title()
