@tool class_name ModulateTexture extends Texture2D

@export var origin: Texture2D
@export var modulate := Color.WHITE

func _draw(to_canvas_item: RID, pos: Vector2, origin_modulate: Color, transpose: bool) -> void:
	if !origin: return
	origin.draw(to_canvas_item, pos, origin_modulate * modulate, transpose)

func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, origin_modulate: Color, transpose: bool) -> void:
	if !origin: return
	origin.draw_rect(to_canvas_item, rect, tile, origin_modulate * modulate, transpose)

func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, origin_modulate: Color, transpose: bool, clip_uv: bool) -> void:
	if !origin: return
	origin.draw_rect_region(to_canvas_item, rect, src_rect, origin_modulate * modulate, transpose, clip_uv)

func _get_width() -> int:
	if !origin: return 0
	return origin.get_width()

func _get_height() -> int:
	if !origin: return 0
	return origin.get_height()

func _has_alpha() -> bool:
	if !origin: return false
	return origin.has_alpha()
