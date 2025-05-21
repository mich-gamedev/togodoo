extends HBoxContainer

@onready var block: Block = $Block
@onready var title: RichTextLabel = $Title
@onready var left: HSeparator = $Left
@onready var right: HSeparator = $Right

func _update_block() -> void:
	title.text = block.get_title()
	left.size_flags_stretch_ratio = block.get_arg("left_ratio")
	right.size_flags_stretch_ratio = block.get_arg("right_ratio")
	if !(block.get_title() and block.get_arg("show_title")):
		title.hide()
		right.hide()
	else:
		title.show()
		right.show()

func _on_title_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)
