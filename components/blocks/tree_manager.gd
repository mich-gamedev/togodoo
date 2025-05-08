class_name TreeManager extends Object

class Signals:
	signal block_added(dict: Dictionary, idx: int)
	signal pre_block_removed(dict: Dictionary, idx: int)

static var items: Array[Dictionary]
static var signals = Signals.new()

static func load_file(path: String) -> void:
	assert(FileAccess.file_exists(path), "File at path \'%s\' couldn't be found." % path)
	var file = FileAccess.open(path, FileAccess.READ)
	print(error_string(FileAccess.get_open_error()))
	var i: int
	while file.get_position() < file.get_length():
		i += 1
		var line = file.get_line()
		var parsed = LineParser.parse_line(line)
		for back in i:
			if items[i - back].indents < parsed.indents:
				parsed.parent = i - back
				break #TODO continue here


static func create_default_block(type: String, parent_idx: int) -> Dictionary:
	assert(
		FileManager.block_types.has(type),
		"No type found for block of type %s" % type
	)
	assert(
		FileManager.get_block_config_by_type(items[parent_idx].type).get_value("logic", "can_have_children", false),
		"Provided parent of index [%s] cannot have children." % parent_idx
	)
	var dict = LineParser.parse_line(_get_block_parse_line(type))
	dict.parent = parent_idx
	_add_block(dict)
	return dict

static func create_block_from_dict(dict: Dictionary, parent_idx: int) -> void:
	dict.parent = parent_idx
	_add_block(dict)

static func set_property(idx: int, property: String, value: Variant, reset_property_list := true) -> void:
	items[idx][property] = value
	PropertyBus.property_changed.emit(idx, property, value, reset_property_list)

static func get_property(idx: int, property: String) -> Variant:
	return items[idx][property]

static func get_idx_by_child(parent: int, child_idx: int) -> int:
	return items[parent].children[child_idx]

static func remove_block(idx: int) -> void:
	var dict = items[idx]
	signals.pre_block_removed.emit(dict, idx)
	items[dict.parent].children.erase(idx)
	items.remove_at(idx)

static func get_valid_parent(parent_idx: int) -> int:
	var cfg = FileManager.get_block_config_by_type(items[parent_idx].type)
	if !cfg.get_value("logic", "can_have_children", false):
		return items[parent_idx].parent
	return parent_idx

""" PRIVATES """

static func _get_block_parse_line(type: String) -> String:
	var cfg = FileManager.get_block_config_by_type(type)
	return "[{type}] New {name}".format({"type": type, "name": cfg.get_value("display", "display_name")})

static func _add_block(dict: Dictionary) -> void:
	dict.indents = items[dict.parent].indents + 1
	items.append(dict)
	var idx = items.size() - 1
	items[dict.parent].children.append(idx)
	signals.block_added.emit(dict, idx)
