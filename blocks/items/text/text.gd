extends RichTextLabel

@onready var block: Block = $Block

func _update_block() -> void:
	text = block.get_title()
