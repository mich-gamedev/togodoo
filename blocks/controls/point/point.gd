extends HFlowContainer

@onready var block: Block = $Block
@onready var bullet_point: Label = $BulletPoint
@onready var label: RichTextLabel = $RichTextLabel

func _update_block() -> void:
	bullet_point.text = block.get_arg("point_symbol")
	bullet_point.add_theme_color_override(&"font_color", block.get_arg("point_color"))
	label.text = block.get_title()
