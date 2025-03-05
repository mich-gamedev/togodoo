extends MarginContainer

@onready var spacer: Control = $"../Spacer"
@onready var block: Block = $Block
@onready var v_separator: VSeparator = $"../VSeparator"

func _update_block() -> void:
	spacer.custom_minimum_size.x = block.get_arg("quote_offset")
	v_separator.get_theme_stylebox(&"separator").color = block.get_arg("quote_color")
	v_separator.get_theme_stylebox(&"separator").thickness = block.get_arg("quote_width")
	add_theme_constant_override(&"margin_left", block.get_arg("margin"))
