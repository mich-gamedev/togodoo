extends Button
class_name MobileMenuButton

@export var panel_to_show:MarginContainer
@export var panel_sorter:VBoxContainer

@export var items:Array[MobileActionFunction]

const PREFERENCES = preload("uid://bq821lexcvdre")
const MOD_MANAGER = preload("uid://d0xlphou0hs56")

func _ready() -> void:
	pressed.connect(panel_to_show.show)
	pressed.connect(_on_pressed)

func _on_pressed():
	# Clear all children
	for child:Node in panel_sorter.get_children(): child.queue_free() 
	for item in items:
		if not item.is_seperator:
			var new_button := Button.new()
			new_button.text = item.text
			new_button.pressed.connect(_actionbar_pressed.bind(item.text))
			new_button.disabled = !item.enabled
			panel_sorter.add_child(new_button)
		else:
			panel_sorter.add_child(HSeparator.new())
		

func _actionbar_pressed(content:String):
	match content:
		# FILE
		"project manager":
			get_tree().change_scene_to_file("res://scenes/project_manager/mobile/project_manager.tscn")
		"save as":
			var dialog = FileDialog.new()
			dialog.access = FileDialog.ACCESS_FILESYSTEM
			dialog.use_native_dialog = true
			dialog.add_filter("*.togodoo", "Togodoo Project")
			dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			dialog.current_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
			dialog.file_selected.connect(PropertyBus.save_requested.emit)
			add_child(dialog)
			dialog.show()
		"save":
			PropertyBus.save_requested.emit("")
		"open":
			var dialog = FileDialog.new()
			dialog.access = FileDialog.ACCESS_FILESYSTEM
			dialog.use_native_dialog = true
			dialog.add_filter("*.togodoo", "Togodoo Project")
			dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			dialog.current_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
			dialog.file_selected.connect(_open_file)
			add_child(dialog)
			dialog.show()
		"show in filesystem":
			if FileManager.file_path.begins_with("res://"): return
			OS.shell_open(FileManager.file_path.get_base_dir())
		"open in text editor":
			if FileManager.file_path.begins_with("res://"): return
			OS.shell_open(FileManager.file_path)
		"save project as godot scene":
			var dialog = FileDialog.new()
			dialog.access = FileDialog.ACCESS_FILESYSTEM
			dialog.use_native_dialog = true
			dialog.add_filter("*.tscn,*.scn,*.tres,*.res", "PackedScene")
			dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			dialog.current_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
			dialog.file_selected.connect(_save_as_godot_scene)
			add_child(dialog)
			dialog.show()
		# PREFERENCES
		"preferences":
			var inst = PREFERENCES.instantiate()
			get_tree().current_scene.add_child(inst)
			inst.show()
		"open user data folder":
			OS.shell_show_in_file_manager(OS.get_user_data_dir())
		"manage mods":
			var inst = MOD_MANAGER.instantiate()
			get_tree().current_scene.add_child(inst)
			inst.show()
		# HELP
		"open docs":
			OS.shell_open("https://github.com/mich-gamedev/togodoo/wiki")
		"open github":
			OS.shell_open("https://github.com/mich-gamedev/togodoo")
		"join discord server":
			OS.shell_open("https://discord.gg/V5ZXFJnD6v")

func _open_file(path: String) -> void:
	OS.create_process(OS.get_executable_path(), ["--project=%s" % path])
	
func _save_as_godot_scene(path: String) -> void:
	var scene = PackedScene.new()
	var err = scene.pack(%BlockDisplay)
	if err:
		push_error("Failed saving project as godot scene, with following error: ", error_string(err))
	else:
		ResourceSaver.save(scene, path)
