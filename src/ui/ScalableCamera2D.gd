extends Camera2D

@onready var tilemap_layer = get_node("../Layer_ground")

func _ready():
	var tile_set = tilemap_layer.tile_set
	if tile_set:
		var cell_size = tile_set.tile_size
		var used_rect = tilemap_layer.get_used_rect()
		var tilemap_size_pixels = used_rect.size * cell_size
		var viewport_size = get_viewport_rect().size
		
		if cell_size.x > 0 and cell_size.y > 0:
			var zoom_x = viewport_size.x / tilemap_size_pixels.x
			var zoom_y = viewport_size.y / tilemap_size_pixels.y

			zoom = Vector2(min(zoom_x, zoom_y), min(zoom_x, zoom_y))
		else:
			printerr("Error: Invalid cell size in TileSet!")
	else:
		printerr("Error: TileMapLayer does not have a TileSet assigned!")
