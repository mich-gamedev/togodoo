extends RichTextLabel

@onready var block: Block = $Block

func _update_block() -> void:
	if block.get_arg("use_custom_color"):
		add_theme_color_override(&"default_color", block.get_arg("custom_color"))
	if block.get_arg("do_math_formatting"):
		text = "[symbol_coloring]%s" % block.get_title()
	else:
		text = block.get_title()

func _on_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)
