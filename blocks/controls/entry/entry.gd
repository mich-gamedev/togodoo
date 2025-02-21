extends HFlowContainer

@onready var block: Block = $Block

@onready var check_box: CheckBox = $CheckBox
@onready var label: RichTextLabel = $RichTextLabel

func _update_block() -> void:
	check_box.button_pressed = block.args.state
	label.text = block.get_title()
