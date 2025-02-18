class_name LineParser extends Object

static func parse_line(line: String) -> Dictionary:
	var args = {}
	args.raw = line
	args.indents = line.get_slice("[", 0).length()

	var from = line.find("[")
	var to = line.find("]")
	args.raw_args =line.substr(from + 1, to - from - 1)
	var tags := Array(String(args.raw_args).split(" "))
	tags.pop_front()
	for i in tags:
		var elements =
	print(args)

	return args
