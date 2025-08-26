extends HBoxContainer

@onready var tree: BlockTree = %Tree

func _ready() -> void:
	update("vanilla", "editor/favorite_blocks", Settings.get_setting("vanilla", "editor/favorite_blocks"))
	Settings.signals.setting_changed.connect(update)

func update(mod: String, setting: String, value: Variant) -> void:
	for i in get_children():
		i.queue_free()
	if [mod, setting] == ["vanilla", "editor/favorite_blocks"]:
		for i in value:
			var inst : Button = preload("uid://bfellyvhea3i3").instantiate()
			var cfg = FileManager.get_block_config_by_type(i)
			inst.icon = load(cfg.get_value("display", "icon"))
			inst.block_type = i
			add_child(inst)
			inst.pressed.connect(_pressed.bind(i))

func _pressed(type: StringName) -> void:
	TreeManager.create_default_block(type, TreeManager.get_valid_parent(tree.tree_items.find_key(tree.get_selected())) if tree.get_selected() else TreeManager.get_root())
