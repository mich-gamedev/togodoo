class_name Block extends Node

var args : Dictionary

func get_type() -> String:
	return args.type

func get_title() -> String: ## returns the title of the block, or the [code]TEXT[/code] in [code][args] TEXT[/code]
	return args.title

func get_indents() -> int: ## returns the indentation level of the block
	return args.indents

func get_raw() -> String: ## returns the raw line of the block as a string
	return args.raw

func get_raw_args() -> String:
	return args.raw_args
func get_arg(arg: String) -> Variant:
	return args.get(arg, FileManager.get_block_config(FileManager.block_types[get_type()]).get_value("properties", arg))

func get_idx() -> int:
	return TreeManager.items.find_key(args)

func set_arg(arg: String, value: Variant, reset_property_list: bool = true) -> void:
	PropertyBus.property_changed.emit.call_deferred(
		get_idx(),
		arg,
		value,
		reset_property_list
	)

func _ready() -> void:
	PropertyBus.property_changed.connect(_on_property_changed)

func _on_property_changed(index: int, property: String, value: Variant, reset_property_list: bool) -> void:
	if index == get_idx():
		args[property] = value
		owner.propagate_call("_update_block")
