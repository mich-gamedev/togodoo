class_name PropertyBlock extends Control

@export var value_node: Node
@export var value_property: StringName
@export var custom_function: StringName ## if set, value_property is ignored for changing it's value
@export var reset_button: Button

var index: int
var responsible_property: StringName
var property_usage_tags: PackedStringArray
var default_value: Variant
var for_setting: bool ## NOTE: if true, only responsible_property and responsible_mod are relevant
var show_reset: bool = true
var responsible_mod: StringName

signal display_requested(value: Variant)

func _ready() -> void:
	if reset_button:
		reset_button.visible = show_reset
		reset_button.pressed.connect(_reset_value)

func display_value(value: Variant) -> void:
	if value_node and custom_function and (value_node.has_method(custom_function)):
		value_node.call(custom_function, value)
	elif value_node and value_property in value_node:
		value_node.set(value_property, value)

	if reset_button and show_reset: reset_button.visible = value_node[value_property] != default_value
	display_requested.emit(value)

func property_change_emit() -> void:
	if !is_node_ready(): return
	if reset_button and show_reset: reset_button.visible = value_node[value_property] != default_value
	print("emitting property change: %d, %s, %s" % [index, responsible_property, value_node[value_property]])
	if !for_setting:
		PropertyBus.property_changed.emit.call_deferred(
			index,
			responsible_property,
			value_node[value_property],
			false
		)
	else:
		Settings.set_setting(responsible_mod, responsible_property, value_node[value_property])

func _reset_value() -> void:
	display_value(default_value)
	property_change_emit()
