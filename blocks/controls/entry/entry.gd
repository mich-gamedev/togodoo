extends HFlowContainer

@onready var block: Block = $Block

@onready var check_box: CheckBox = $Control/CheckBox
@onready var label: RichTextLabel = $RichTextLabel

func _update_block() -> void:
	check_box.button_pressed = block.get_arg("state")
	label.text = block.get_title()
