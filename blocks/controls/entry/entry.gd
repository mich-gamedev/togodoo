extends Control

@onready var block: Block = $Block

@onready var check_box: CheckBox = $Control/CheckBox
@onready var label: RichTextLabel = $RichTextLabel

func _update_block() -> void:
	check_box.set_pressed_no_signal(block.get_arg("state"))
	label.text = block.get_title()

func _on_check_box_toggled(toggled_on: bool) -> void:
	PropertyBus.property_changed.emit.call_deferred(
		block.get_idx(),
		"state",
		toggled_on,
		true
	)
