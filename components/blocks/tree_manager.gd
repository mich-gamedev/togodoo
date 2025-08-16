class_name TreeManager extends Object

class Signals:
	signal block_added(dict: Dictionary, idx: int)
	signal pre_block_removed(dict: Dictionary, idx: int)
	signal block_moved(dict: Dictionary, idx: int, from: int, to: int, at: int)
	signal tree_changed
static var signals := Signals.new() ## an object that holds signals for the [TreeManager] singleton. see [TreeManager.Signals]
## stores the info of all currently loaded blocks, can be used for more advanced things not covered by methods if needed.[br]
## [color=yellow]Warning:[/color] the order of blocks is unstable and can be out of order from the tree. [br]
static var items: Dictionary[int, Dictionary]
static var _root: int = -1 ## the index of the root node, or [code]-1[/code] if no root was yet created.
static var _itr: int = 0

#region PUBLIC FUNCS

static func load_file(path: String) -> void: ## adds all the blocks from a project file at [param path]
	assert(FileAccess.file_exists(path), "File at path \'%s\' couldn't be found." % path)
	var file = FileAccess.open(path, FileAccess.READ)
	print("PROJECT LOAD STATUS: ", error_string(FileAccess.get_open_error()))
	var i: int = 0
	while file.get_position() < file.get_length():
		var line = file.get_line()
		var parsed = LineParser.parse_line(line)
		if parsed.is_empty(): continue
		var added: bool = false
		for back in i:
			if items[i - back - 1].indents < parsed.indents:
				create_block_from_dict(parsed, i - back - 1)
				added = true
				break #TODO continue here
		if !added:
			create_block_from_dict(parsed, -1)
		i += 1

static func save_file(path: String) -> Error: ## formats all the blocks into project syntax and saves them to the file
	var file = FileAccess.open(path, FileAccess.WRITE)
	if FileAccess.get_open_error(): return FileAccess.get_open_error()
	for i in get_sorted_blocks():
		file.store_line(LineParser.parse_dict(items[i]))
	return OK

static func create_default_block(type: String, parent_idx: int) -> Dictionary: ## creates a new block of type [param type] to the block at index [param parent_idx]
	assert(
		FileManager.block_types.has(type),
		"No type found for block of type %s" % type
	)
	assert(
		items.is_empty() or FileManager.get_block_config_by_type(items[parent_idx].type).get_value("logic", "can_have_children", false),
		"Provided parent of index [%s] cannot have children." % parent_idx
	)
	var dict = LineParser.parse_line(_get_block_parse_line(type))
	dict.parent = parent_idx if !items.is_empty() else -1
	_add_block(dict)
	return dict

static func create_block_from_dict(dict: Dictionary, parent_idx: int) -> void: ## creates a new block based on [param dict] to the block at index [param parent_idx]
	dict.parent = parent_idx
	_add_block(dict)

static func set_property(idx: int, property: String, value: Variant, reset_property_list := true) -> void: ## sets [param property] of block at [param idx] to [param value]. [param reset_property_list] is used to prevent recursion by the property list, and shouldn't normally be used otherwise.
	items[idx][property] = value
	if property == "title":
		var regex = RegEx.new()
		regex.compile("\\[.*?\\]") #strips bbcode tags
		items[idx].stripped_title = regex.sub(value, "", true)
	PropertyBus.property_changed.emit(idx, property, value, reset_property_list)

static func get_property(idx: int, property: String) -> Variant: ## returns the value of [param property] of block at [param idx]
	return items[idx].get(property, FileManager.get_block_config_by_type(items[idx].type).get_value("properties", property))

static func get_title(idx: int) -> String:
	return items[idx].title

static func get_indents(idx: int) -> int:
	return items[idx].indents

static func get_type(idx: int) -> String:
	return items[idx].type

static func get_parent(idx: int) -> int:
	return items[idx].parent

static func get_children(idx: int) -> Array:
	return items[idx].get(&"children", [])

static func get_bbcode_stripped_title(idx: int) -> String:
	return items[idx].stripped_title

static func get_idx_by_child(parent: int, child_idx: int) -> int: ## returns the global index of the block based on it's index within it's parent
	return items[parent].children[child_idx]

static func get_idx_by_dict(dict: Dictionary) -> int:
	return items.find_key(dict)

static func remove_block(idx: int) -> void: ## removes the block at [param idx]
	print("deleting ", items[idx].title)
	var dict = items[idx]
	signals.pre_block_removed.emit(dict, idx)
	if dict.parent != -1: items[dict.parent].children.erase(idx)
	for i in dict.children:
		remove_block(i)
	items.erase(idx)
	signals.tree_changed.emit()

static func get_valid_parent(parent_idx: int) -> int: ## utility function that returns [param parent_idx] if the block at that index can have children, otherwise it's parent's index.
	var cfg = FileManager.get_block_config_by_type(items[parent_idx].type)
	if !cfg.get_value("logic", "can_have_children", false):
		return items[parent_idx].parent
	return parent_idx

static func get_config(idx: int) -> ConfigFile:
	return FileManager.get_block_config_by_type(items[idx].type)

static func move_block(idx: int, to_parent: int, at: int = -1) -> void:
	var from: int = items[idx].parent
	items[idx].parent = to_parent
	items[from].children.erase(idx)
	items[idx].indents = get_indents(to_parent) + 1
	print("NEW PARENT: ", get_title(to_parent))
	if at == -1:
		Array(items[to_parent].children).append(idx)
	else:
		Array(items[to_parent].children).insert(at, idx)
	_fix_child_indents(idx)
	print("└─NEW CHILDREN: ", get_children(to_parent).map(func(i): return get_title(i)))
	signals.block_moved.emit(items[idx], idx, from, to_parent, at)
	signals.tree_changed.emit()
	print("--- New Tree ---")
	for i in get_sorted_blocks():
		var item = items[i]
		print_rich("	".repeat(item.indents), item.title)
	print("---")

static func can_spawn(type: String) -> bool:
	if !items.is_empty(): return true
	return FileManager.get_block_config(FileManager.block_types[type]).get_value("logic", "can_have_children", false)

static func get_sorted_blocks() -> Array[int]:
	if items.is_empty(): return []
	var arr: Array[int] = []
	_add_i_and_children(arr, _root)
	return arr

static func get_root() -> int:
	return _root
#endregion

#region PRIVATE FUNCS
static func _get_block_parse_line(type: String) -> String:
	var cfg = FileManager.get_block_config_by_type(type)
	return "[{type}] New {name}".format({"type": type, "name": cfg.get_value("display", "display_name")})

static func _add_block(dict: Dictionary) -> void:
	dict.indents = (items[dict.parent].indents + 1) if dict.parent != -1 else 0
	items[_itr] = dict
	var idx = _itr
	if dict.parent != -1:
		items[dict.parent].children.append(idx)
	else:
		_root = idx
	signals.block_added.emit(dict, idx)
	signals.tree_changed.emit()
	_itr += 1

static func _add_i_and_children(arr: Array[int], i: int) -> void:
	arr.append(i)
	for j in items[i].get(&"children", []):
		_add_i_and_children(arr, j)

static func _fix_child_indents(idx: int) -> void:
	for i in get_children(idx):
		items[i].indents = items[idx].indents + 1
#endregion
