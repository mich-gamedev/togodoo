class_name PropertyBlock extends Control

@export var value_node: Node
@export var value_property: StringName

var index: int
var responsible_property: StringName


func display_value(value: Variant) -> void:
	if value_node and value_property in value_node:
		value_node.set(value_property, value)
		print("set property value: ", value_node[value_property])
	elif value_node:
		push_error("%s's value_node doesn't have a defined %s" % [scene_file_path, value_property])

func property_change_emit() -> void:
	if !is_node_ready(): return
	PropertyBus.property_changed.emit.call_deferred(
		index,
		responsible_property,
		value_node[value_property]
	)
