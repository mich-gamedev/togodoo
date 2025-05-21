extends Control

@onready var block: Block = $Block

@onready var check_box: CheckBox = $Control/CheckBox
@onready var label: RichTextLabel = $RichTextLabel

func _update_block() -> void:
	check_box.set_pressed_no_signal(block.get_arg("state"))
	label.text = block.get_title()

func _on_check_box_toggled(toggled_on: bool) -> void:
	block.set_arg("state", toggled_on, true)

func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)
