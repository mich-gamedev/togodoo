extends Popup

@onready var list: ItemList = %Cmds

func _ready() -> void:
	list.clear()
	CommandPallete.update_commands()
	var cmds :=  CommandPallete.get_commands()
	for i in cmds:
		var cmd := cmds[i]
		var item = list.add_item(cmd.text, cmd.icon)
		list.set_item_disabled(item, !cmd.is_valid())
		list.set_item_metadata(item, i)
	list.sort_items_by_text()

func _line_edit_text_changed(txt: String) -> void:
	txt = txt.replace(" ", "_")
	list.clear()
	var cmds := CommandPallete.get_commands()
	var sorted := CommandPallete.get_commands().keys()
	sorted.sort_custom(func(a, b): return txt.similarity(a) > txt.similarity(b))
	for i in sorted:
		var cmd := cmds[i]
		var item = list.add_item(cmd.text, cmd.icon)
		list.set_item_disabled(item, !cmd.is_valid())
		list.set_item_metadata(item, i)

func _line_edit_text_submitted(new_text: String) -> void:
	CommandPallete.run_command(list.get_item_metadata(0))


func _cmds_item_activated(index: int) -> void:
	CommandPallete.run_command(list.get_item_metadata(index))
