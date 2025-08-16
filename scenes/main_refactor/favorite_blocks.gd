extends HBoxContainer

@onready var tree: BlockTree = %Tree

func _ready() -> void:
	update()
	Settings.signals.setting_changed.connect(update.unbind(3))

func update() -> void:
	for i in Settings.get_setting("vanilla", "editor/favorite_blocks"):
		var inst : Button = Button.new() as Button
		var cfg = FileManager.get_block_config_by_type(i)
		inst.icon = load(cfg.get_value("display", "icon"))
		inst.add_theme_constant_override(&"icon_max_width", 16)
		add_child(inst)
		inst.pressed.connect(_pressed.bind(i))

func _pressed(type: StringName) -> void:
	TreeManager.create_default_block(type, TreeManager.get_valid_parent(tree.tree_items.find_key(tree.get_selected())) if tree.get_selected() else TreeManager.get_root())
