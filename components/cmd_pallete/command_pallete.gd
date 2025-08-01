class_name CommandPallete extends Object

static var _cmds: Dictionary[StringName, Command]

static func _static_init() -> void:
	update_commands.call_deferred()

static func update_commands() -> void:
	for i in ResourceLoader.list_directory("res://components/cmd_pallete/commands/"):
		var resource = load("res://components/cmd_pallete/commands/" + i)
		if resource is Command:
			_cmds[resource.id] = resource

static func is_command_valid(id: StringName) -> bool:
	if !id in _cmds:
		return false
	return _cmds[id].is_valid()

static func run_command(id: StringName) -> void:
	_cmds[id].run()

static func get_commands() -> Dictionary[StringName, Command]:
	return _cmds.duplicate()
