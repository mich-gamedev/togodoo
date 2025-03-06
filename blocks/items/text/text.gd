extends RichTextLabel

@onready var block: Block = $Block

func _ready() -> void:
	install_effect(RichTextSymbolColoring.new())

func _update_block() -> void:
	if block.get_arg("do_math_formatting"):
		text = "[symbol_coloring]%s" % block.get_title()
	else:
		text = block.get_title()
	#TODO: add automatic symbol greying
	#var inside_symbol_chunk := false
	#var i
	#for i in text.length():
		#if !inside_symbol_chunk and text[i] in symbols:
			#inside_symbol_chunk = true
