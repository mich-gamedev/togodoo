class_name PropertyBlock extends Control

@export var value_node: Node
@export var value_property: StringName
@export var custom_function: StringName ## if set, value_property is ignored for changing it's value

var index: int
var responsible_property: StringName


func display_value(value: Variant) -> void:
	if value_node and custom_function and (custom_function in value_node):
		value_node.call(custom_function, value)
	elif value_node and value_property in value_node:
		value_node.set(value_property, value)
		print("set property value: ", value_node[value_property])

func property_change_emit() -> void:
	if !is_node_ready(): return
	PropertyBus.property_changed.emit.call_deferred(
		index,
		responsible_property,
		value_node[value_property]
	)
