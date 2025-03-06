@tool
# Having a class name is handy for picking the effect in the Inspector.
class_name RichTextSymbolColoring
extends RichTextEffect


# To use this effect:
# - Enable BBCode on a RichTextLabel.
# - Register this effect on the label.
# - Use [symbol_coloring param=2.0]hello[/symbol_coloring] in text.
var bbcode := "symbol_coloring"

const symbols : String = "!@$%&(){}[]|:\"\'><Δ~"
const light_symbols: String = "^*-+÷±∓√≅=./"

func get_text_server() -> TextServer:
	return TextServerManager.get_primary_interface()

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var char = String.chr(get_text_server().font_get_char_from_glyph_index(char_fx.font, 1, char_fx.glyph_index))
	if char in symbols:
		char_fx.color = Utils.COLORS[Utils.ColorTags.SURFACE_2]
		return true
	if char in light_symbols:
		char_fx.color = Utils.COLORS[Utils.ColorTags.OVERLAY_2]
		return true
	return false
