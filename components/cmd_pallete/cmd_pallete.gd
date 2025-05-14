extends Node

var _cmds: Dictionary[StringName, Command] = {}

func add_command(id: StringName) -> Command:
	if _cmds.has(id):
		push_error("Command already found for id '%s'" % id)
		return null
	var cmd = Command.new()
	_cmds[id] = cmd
	return cmd

func remove_command(id: StringName) -> void:
	_cmds.erase(id)

func insert_command(id: StringName, command: Command) -> void:
	_cmds[id] = command

func get_command(id: StringName) -> Command:
	if !_cmds.has(id):
		push_error("No command found with id '%s'" % id)
		return null
	return _cmds[id]

func get_id(command: Command) -> StringName:
	return _cmds.find_key(command)

func call_command(id: StringName) -> Variant:
	if !_cmds.has(id):
		push_error("No command found with id '%s'" % id)
		return null
	return _cmds[id].function.call()

func is_valid(id: StringName) -> bool:
	if !_cmds.has(id):
		push_error("No command found with id '%s'" % id)
		return false
	return _cmds[id].is_valid.call()

func id_exists(id: StringName) -> bool:
	return _cmds.has(id)

func get_commands(prefix: String = "") -> Array[StringName]:
	if !prefix: return _cmds.keys()
	else:
		return _cmds.keys().filter(
			func(i: String): return i.begins_with(prefix)
		)

func _unhandled_input(event: InputEvent) -> void:
	for id in _cmds:
		for input: InputEvent in _cmds[id].inputs:
			if event.is_match(input):
				call_command(id)
