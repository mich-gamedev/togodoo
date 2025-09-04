@tool
extends Resource
class_name MobileActionFunction

@export var text:String:
	set(new_var):
		text = new_var
		if not is_seperator: resource_name = new_var
@export var is_seperator:bool:
	set(new_var):
		is_seperator = new_var
		if is_seperator: resource_name = "-------"
@export var enabled:bool = true
