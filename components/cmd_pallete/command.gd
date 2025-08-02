@icon("res://resources/themes/cli.svg")
abstract class_name Command extends Resource

@export_group("Display")
@export var text: String
@export var icon: Texture2D
@export_group("Logic")
@export var id: StringName
@export var include_in_history: bool = true

abstract func _run() -> void
abstract func _is_valid() -> bool

func is_valid() -> bool:
	return _is_valid()

func run() -> void:
	if is_valid():
		_run()
	else:
		push_error("Command '%s' not currently valid." % text)
