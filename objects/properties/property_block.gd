class_name PropertyBlock extends HBoxContainer

@export var value_node: Node
@export var value_property: StringName

var index: int
var responsible_property: StringName

func display_value(value: Variant) -> void:
	value_node.set(value_property, value)

func property_change_emit() -> void:
	PropertyBus.property_changed.emit.call_deferred(
		index,
		responsible_property,
		value_node[value_property]
	)
