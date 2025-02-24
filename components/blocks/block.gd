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

func get_arg(name: String) -> Variant:
	print(FileManager.get_block_config(FileManager.block_types[get_type()]).get_section_keys("properties"))
	return args.get(name, FileManager.get_block_config(FileManager.block_types[get_type()]).get_value("properties", name))
