extends Node

signal property_changed(item: int, property: StringName, value: Variant, reset_property_list: bool)

signal save_requested(path: String )
signal backup_requested # not implemented yet

signal favorite_block_changed(new: Array)
