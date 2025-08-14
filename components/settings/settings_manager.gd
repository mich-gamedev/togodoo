@icon("res://resources/themes/settings.svg")
class_name Settings extends Object

const user_dir := "user://settings/"
const defaults_dir := "res://components/settings/defaults/"
const mod_info_dir := "user://mods/%s/info.cfg"
const mod_pck_dir := "user://mods/%s/index.pck"
const mod_fallback_dir := "user://mods/%s/fallback.cfg"
const mods_dir := "user://mods/"
const USER := &"user"
const FALLBACK = &"fallback"

static var configs := {}
static var signals := Signals.new()


static var settings_formatting : Dictionary[String, String] = {
	"SYSTEM_DIR_DESKTOP": OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP),
	"SYSTEM_DIR_DCIM": OS.get_system_dir(OS.SYSTEM_DIR_DCIM),
	"SYSTEM_DIR_DOCUMENTS": OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS),
	"SYSTEM_DIR_DOWNLOADS": OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS),
	"SYSTEM_DIR_MOVIES": OS.get_system_dir(OS.SYSTEM_DIR_MOVIES),
	"SYSTEM_DIR_MUSIC": OS.get_system_dir(OS.SYSTEM_DIR_MUSIC),
	"SYSTEM_DIR_PICTURES": OS.get_system_dir(OS.SYSTEM_DIR_PICTURES),
	"SYSTEM_DIR_RINGTONES": OS.get_system_dir(OS.SYSTEM_DIR_RINGTONES),
}

class Signals:
	signal setting_changed(mod: String, setting: String, value: Variant)
	signal saved(mod: String)
	signal mod_loaded(mod: String)
	signal pck_loaded(path: String)

static func initialize() -> void:
	print("initializing")
	DirAccess.make_dir_recursive_absolute(user_dir)
	DirAccess.make_dir_recursive_absolute(get_setting_default("vanilla", "file_system/mod_folder"))
	DirAccess.make_dir_absolute(get_setting_default("vanilla", "file_system/mod_folder") + "vanilla/")
	for i in DirAccess.get_files_at("res://vanilla/"):
		print("copying files to mod folder")
		DirAccess.copy_absolute("res://vanilla/" + i, get_setting_default("vanilla", "file_system/mod_folder") + "vanilla/" + i)

static func find_mods() -> void:
	if !DirAccess.dir_exists_absolute(user_dir):
		initialize()
	for i in DirAccess.get_directories_at(mods_dir):
		setup_mod(i)
	FileManager.load_mods()

static func setup_mod(mod: String) -> Error:
	var file = mod + ".cfg"
	if !FileAccess.file_exists(defaults_dir + file):
		DirAccess.copy_absolute(mod_fallback_dir % mod, defaults_dir + file)
	if !configs.has(mod):
		var dict := {}
		if !FileAccess.file_exists(defaults_dir + file):
			push_error("default config file for the \'%s\' mod couldn't be found" % mod)
			return ERR_FILE_BAD_PATH
		else: var cfg := ConfigFile.new() ; cfg.load(defaults_dir + file) ; dict.fallback = cfg

		if !FileAccess.file_exists(user_dir + file):
			push_warning("user config file for the \'%s\' mod couldn't be found" % mod)
			dict.user = ConfigFile.new()
		else: var cfg := ConfigFile.new() ; cfg.load(user_dir + file) ; dict.user = cfg
		configs[mod] = dict

		if FileAccess.file_exists(mod_pck_dir % mod):
			print("LOADING PCK %s" % mod_pck_dir % mod)
			ProjectSettings.load_resource_pack(mod_pck_dir % mod)
			signals.pck_loaded.emit(mod_pck_dir % mod)
		else:
			push_warning("no index.pck found for the \'%s\' mod at \'%s\'." % [mod, mod_pck_dir % mod])
		signals.mod_loaded.emit(mod)
	return OK

static func get_setting_default(mod: String, key: String) -> Variant:
	if !configs.has(mod):
		var err = setup_mod(mod)
		if err: return null

	var result = (configs[mod][FALLBACK] as ConfigFile).get_value("properties", key)
	if typeof(result) == TYPE_STRING:
		result = format(result)
	return result

static func get_setting(mod: String, key: String) -> Variant:
	if !configs.has(mod):
		var err = setup_mod(mod)
		if err: return null
	var result
	if !configs[mod].has(USER):
		result = (configs[mod][FALLBACK] as ConfigFile).get_value("properties", key)
		if typeof(result) == TYPE_STRING:
			result = format(result)
		return result
	result = (configs[mod][USER] as ConfigFile).get_value("properties", key, (configs[mod][FALLBACK] as ConfigFile).get_value("properties", key))
	if typeof(result) == TYPE_STRING:
		result = format(result)
	return result

static func get_setting_usage(mod: String, key: String) -> PackedStringArray:
	if !configs.has(mod):
		var err = setup_mod(mod)
		if err: return PackedStringArray()
	print("usage result: %s -> %s" % [mod + "/" + key, (configs[mod][FALLBACK] as ConfigFile).get_value("usage", key, "none").split(",")])
	return format((configs[mod][FALLBACK] as ConfigFile).get_value("usage", key, "none")).split(",")

static func get_setting_usage_string(mod: String, key: String) -> String:
	if !configs.has(mod):
		var err = setup_mod(mod)
		if err: return ""
	return format((configs[mod][FALLBACK] as ConfigFile).get_value("usage", key))

static func get_setting_info(mod: String, key: String) -> Dictionary:
	if !configs.has(mod):
		var err = setup_mod(mod)
		if err: return {}
	var dict := {}
	dict.mod = mod
	dict.name = key
	dict.user_path = user_dir + mod + ".cfg"
	dict.fallback_path = defaults_dir + mod + ".cfg"
	dict.value = get_setting(mod, key)
	dict.default_value = get_setting_default(mod, key)
	dict.usage = get_setting_usage(mod, key)

	return dict

static func set_setting(mod: String, key: String, value: Variant) -> void:
	if ! configs[mod].has(USER): configs[mod][USER] = ConfigFile.new()
	(configs[mod][USER] as ConfigFile).set_value("properties", key, value)
	signals.setting_changed.emit(mod, key, value)

static func save_config(mod: String) -> void:
	(configs[mod][USER] as ConfigFile).save(user_dir + mod + ".cfg")
	signals.saved.emit(mod)

static func save_all_configs() -> void:
	for i in configs:
		save_config(i)

static func get_mod_info(mod: String) -> ConfigFile:
	var cfg = ConfigFile.new(); cfg.load(mod_info_dir % mod)
	return cfg

static func format(string: String) -> String:
	return string.format(settings_formatting)

static func get_option_string(mod: String, key: String, value: int) -> String:
	for i in get_setting_usage(mod, key):
		if i.begins_with("options"):
			var options := i.trim_prefix("options=").split(";")
			return options[value] if options.size() < value else ""
	return ""
