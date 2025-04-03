extends VBoxContainer

@onready var block: Block = $Block

func _update_block() -> void:
	%ChildContainer.add_theme_constant_override(&"separation", block.get_arg("separation"))
