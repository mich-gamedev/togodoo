@icon("res://resources/themes/settings.svg")
class_name Settings extends Object

const user_dir := "user://settings/"
const defaults_dir := "res://components/settings/defaults/"
const mod_info_dir := "user://mods/%s/info.cfg"
const USER := "user"
const FALLBACK = "fallback"

static var configs := {}

static func initialize() -> void:
	DirAccess.make_dir_recursive_absolute(user_dir)
	DirAccess.make_dir_recursive_absolute(get_seting_default("vanilla", "file_system/mod_folder"))
	DirAccess.make_dir_absolute(get_seting_default("vanilla", "file_system/mod_folder") + "vanilla/")
	for i in DirAccess.get_files_at("res://vanilla/"):
		DirAccess.copy_absolute("res://vanilla/" + i, get_seting_default("vanilla", "file_system/mod_folder") + "vanilla/" + i)

static func find_mods() -> void:
	for i in DirAccess.get_files_at(defaults_dir):
		setup_mod(i.get_slice(".", 0))

static func setup_mod(mod: String) -> Error:
	var file = mod + ".cfg"
	if !configs.has(mod):
		var dict := {}
		if !FileAccess.file_exists(defaults_dir + file):
			push_error("default config file for the \'%s\' mod couldn't be found" % mod)
			return ERR_FILE_BAD_PATH
		else: var cfg := ConfigFile.new() ; cfg.load(defaults_dir + file) ; dict.fallback = cfg

		if !FileAccess.file_exists(user_dir + file): push_warning("user config file for the \'%s\' mod couldn't be found" % mod)
		else: var cfg := ConfigFile.new() ; cfg.load(user_dir + file) ; dict.user = cfg
		configs[mod] = dict
	return OK

static func get_seting_default(mod: String, key: String) -> Variant:
	if !configs.has(mod):
		var err = setup_mod(mod)
		if err: return null
	return (configs[mod][FALLBACK] as ConfigFile).get_value("properties", key)

static func get_setting(mod: String, key: String) -> Variant:
	if !configs.has(mod):
		var err = setup_mod(mod)
		if err: return null
	print(configs[mod])
	if !configs[mod].has(USER):
		print((configs[mod][FALLBACK] as ConfigFile).get_sections())
		return (configs[mod][FALLBACK] as ConfigFile).get_value("properties", key)
	return (configs[mod][USER] as ConfigFile).get_value("properties", key, (configs[mod][FALLBACK] as ConfigFile).get_value("properties", key))

static func get_setting_usage(mod: String, key: String) -> PackedStringArray:
	if !configs.has(mod):
		var err = setup_mod(mod)
		if err: return PackedStringArray()
	return String((configs[mod][FALLBACK] as ConfigFile).get_value("usage", key)).split(",")

static func get_setting_usage_string(mod: String, key: String) -> String:
	if !configs.has(mod):
		var err = setup_mod(mod)
		if err: return ""
	return String((configs[mod][FALLBACK] as ConfigFile).get_value("usage", key))

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
	dict.default_value = get_seting_default(mod, key)
	dict.usage = get_setting_usage(mod, key)

	return dict

static func set_setting(mod: String, key: String, value: Variant) -> void:
	if ! configs[mod].has(USER): configs[mod][USER] = ConfigFile.new()
	(configs[mod][USER] as ConfigFile).set_value("properties", key, value)

static func save_config(mod: String) -> void:
	(configs[mod][USER] as ConfigFile).save(user_dir + mod + ".cfg")

static func get_mod_info(mod: String) -> ConfigFile:
	var cfg = ConfigFile.new(); cfg.load(mod_info_dir % mod)
	return cfg
