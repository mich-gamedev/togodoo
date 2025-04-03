@icon("res://resources/themes/cli.svg")
class_name LineParser extends Object

static func parse_line(line: String) -> Dictionary:
	var args = {}
	args.raw = line
	args.indents = line.get_slice("[", 0).length()

	var from = line.find("[")
	var to = line.find("]")
	args.raw_args =line.substr(from + 1, to - from - 1)
	var filtered_args: String
	var in_quote := false
	for char in args.raw_args:
		if char == "\"":
			in_quote = !in_quote
		if char == " " and in_quote:
			char = "<SPACE>"
		filtered_args += char
	var tags := Array(filtered_args.replace(r"\n", "\n").split(" "))
	print("TAGS: ", tags)
	args.type = tags.pop_front()
	for i: String in tags:
		var expression = Expression.new()
		if expression.parse(i.trim_prefix(i.get_slice("=", 0) + "=").replace("<SPACE>", " ").replace(r"\\n", "\n")):
			print("TAGS error: ", i.trim_prefix(i.get_slice("=", 0) + "=").replace("<SPACE>", " ").replace(r"\\n", "\n"))
			push_error(expression.get_error_text())
		args[i.get_slice("=", 0)] = expression.execute()
	args.title = line.lstrip(" ").replace(line.substr(from, to - from + 1), "").replace(r"\n", "\n").lstrip(" ").rstrip(" ")
	var regex = RegEx.new()
	regex.compile("\\[.*?\\]") #strips bbcode tags
	args.stripped_title = regex.sub(args.title, "", true)

	print(args)

	return args

static func parse_dict(dict: Dictionary) -> String:
	var config = FileManager.get_block_config(FileManager.block_types[dict.type])

	var tags: String
	if config.has_section("properties"): for i in config.get_section_keys("properties"):
		if dict.has(i) and dict[i] != config.get_value("properties", i):
			if tags.is_empty(): tags = " "
			match typeof(dict[i]):
				TYPE_STRING:
					tags += "%s=\"%s\" " % [i, dict[i]]
				TYPE_COLOR:
					tags += "%s=Color(%.3f,%.3f,%.3f,%.3f) " % [i, dict[i].r, dict[i].g, dict[i].b, dict[i].a]
				_:
					tags += "%s=%s " % [i, dict[i]]
	tags = tags.trim_suffix(" ").replace("\n", r"\n")
	var indents: String = ""
	for i in dict.indents:
		indents += " "

	return indents + "[{type}{tags}] {title}".format({"type": dict.type, "tags": tags, "title": dict.title.replace("\n", r"\n")})

static func format_title(title: String) -> String:
	const replacements: Dictionary = {
		"*": "×",
		":-": "÷",
		"+-": "±",
		"-+": "∓",
		"sqrt": "√",
		"~=": "≅",
		"{alpha}": "α",
		"{beta}": "β",
		"{gamma}": "γ", "{Gamma}": "Γ",
		"{delta}": "δ", "{Delta}": "Δ",
		"{epsilon}": "ε",
		"{varepsilon}": "ɛ",
		"{zeta}": "ζ",
		"{eta}": "η",
		"{theta}": "θ", "{Theta}": "Θ",
		"{vartheta}": "ϑ",
		"{iota}": "ι",
		"{kappa}": "κ",
		"{lambda}": "λ", "{Lambda}": "Λ",
		"{mu}": "μ",
		"{nu}": "ν",
		"{xi}": "ξ", "{Xi}": "Ξ",
		"{pi}": "π", "{Pi}": "Π",
		"{rho}": "ρ",
		"{sigma}": "σ", "{Sigma}": "Σ",
		"{tau}": "τ",
		"{upsilon}": "υ",
		"{phi}": "ϕ", "{Phi}": "Φ",
		"{varphi}": "φ",
		"{chi}": "χ",
		"{psi}": "ψ", "{Psi}": "Ψ",
		"{omega}": "ω", "{Omega}": "Ω",
		"{deg}": "°"
	}
	var result := title
	for i in replacements:
		result = result.replace(i, replacements[i])
	#var superscripts : Array[int] = []
	#var temp_result := result
	#while temp_result.contains("^("):
		#superscripts.append(temp_result.find("^("))
		#temp_result = temp_result.substr(superscripts[-1] + 1)
	#for i in superscripts:
	return result
