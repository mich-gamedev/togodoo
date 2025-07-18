#   __                              ___
#__\  \__  _____   _____   _____   _\  \   _____   _____
#\__   __\(  \\ \ (  \\ \ (  \\ \ (  \\ \ (  \\ \ (  \\ \
#  _\  \   \  \\ \ \  \\ \ \  \\ \ \  \\ \ \  \\ \ \  \\ \
#  \____)   \_____) \___  \ \_____) \_____) \_____) \_____) (_)
#__  __  __  __  __    _\  \
#\√\ \√\ \√\ \√\ \√\  \_____) A tree-based todo app







extends Control

const PREF_WINDOW = preload("res://scenes/preferences.tscn")
const MOD_MANAGER = preload("res://scenes/mod_manager.tscn")
const BTN_TEMPLATE = preload("res://scenes/project_template_button.tscn")

func _ready() -> void:
	Settings.find_mods()
	if Settings.get_setting("vanilla", "file_system/default_project_folder") == "_":
		Settings.set_setting("vanilla", "file_system/default_project_folder", OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS))
	if Settings.get_setting("vanilla", "file_system/default_image_folder") == "_":
		Settings.set_setting("vanilla", "file_system/default_image_folder", OS.get_system_dir(OS.SYSTEM_DIR_PICTURES))
	print("started with following arguments: ", OS.get_cmdline_args())
	var args = OS.get_cmdline_args()
	for i in args:
		if i.get_slice("=", 0) == "--project":
			FileManager.file_path = i.get_slice("=", 1)
			get_tree().change_scene_to_file.call_deferred(Settings.get_setting("vanilla", "editor/main_path"))
	for i in DirAccess.get_files_at("res://project_templates/"):
		var inst = BTN_TEMPLATE.instantiate()
		inst.template_path = "res://project_templates/%s" % i
		inst.get_node(^"%Label").text = i.trim_suffix(".togodoo").replace("_", " ")
		%TemplatesContainer.add_child(inst)
	update_recents_list()
	get_tree().root.close_requested.connect(quit)

func update_recents_list() -> void:
	for i in %Recents.get_children():
		i.queue_free()
	for i: String in Settings.get_setting("vanilla", "editor/recent_projects"):
		var inst := Button.new()
		inst.text = i.split("/")[-1].trim_suffix(".togodoo")
		inst.pressed.connect(_dialog_accepted.bind(i))
		inst.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		inst.alignment = HORIZONTAL_ALIGNMENT_LEFT
		%Recents.add_child(inst)

func quit() -> void:
	get_tree().quit()

func _on_new_file_pressed() -> void:
	if Settings.get_setting("vanilla", "editor/open_projects_in_new_window"):
		OS.create_process(OS.get_executable_path(), ["--project=%s" % Settings.get_setting("vanilla", "editor/default_new_project_template")], true)
		get_tree().quit()
	else:
		FileManager.file_path = Settings.get_setting("vanilla", "editor/default_new_project_template")
		get_tree().change_scene_to_file("res://scenes/main_refactor/main.tscn")

func _on_open_file_pressed() -> void:
	var dialog = FileDialog.new()
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.use_native_dialog = true
	dialog.add_filter("*.togodoo", "Togodoo Project")
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.current_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	dialog.file_selected.connect(_dialog_accepted)
	add_child(dialog)
	dialog.show()

func _dialog_accepted(path: String) -> void:
	OS.create_process(OS.get_executable_path(), ["--project=%s" % path], true)
	get_tree().quit()

func _on_contribute_pressed() -> void:
	OS.shell_open("https://github.com/mich-gamedev/togodoo")

func _on_preferences_pressed() -> void:
	var inst = PREF_WINDOW.instantiate()
	add_child(inst)

func _on_manage_mods_pressed() -> void:
	var inst = MOD_MANAGER.instantiate()
	add_child(inst)

func _on_clear_recents_pressed() -> void:
	print("clearing recent list")
	Settings.set_setting("vanilla", "editor/recent_projects", [])
	Settings.save_config("vanilla")
	update_recents_list.call_deferred()
