extends OptionButton

@onready var prop_block: PropertyBlock = $".."

func _ready() -> void:
	for i in prop_block.property_usage_tags:
		if i.begins_with("options="):
			var arr = i.trim_prefix("options=").split(";")
			for option in arr:
				add_item(option.replace("_", " "))
