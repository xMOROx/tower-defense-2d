extends Camera2D

@onready var tilemap_layer = get_node("../Layer_ground") # Adjust the path to your TileMapLayer

func _ready():
	var tile_set = tilemap_layer.tile_set
	if tile_set:
		var cell_size = tile_set.tile_size # Access tile_size from the TileSet
		var used_rect = tilemap_layer.get_used_rect()
		var tilemap_size_pixels = used_rect.size * cell_size
		var viewport_size = get_viewport_rect().size
		
		# print("cell_size: " + cell_size + " used_rect: " + used_rect + " tilemap_size_pixels: " + tilemap_size_pixels + " viewport_size: " + viewport_size)

		if cell_size.x > 0 and cell_size.y > 0:
			var zoom_x = viewport_size.x / tilemap_size_pixels.x
			var zoom_y = viewport_size.y / tilemap_size_pixels.y

			zoom = Vector2(min(zoom_x, zoom_y), min(zoom_x, zoom_y))
			# position = tilemap_size_pixels / 2 * cell_size # Adjust centering
		else:
			printerr("Error: Invalid cell size in TileSet!")
	else:
		printerr("Error: TileMapLayer does not have a TileSet assigned!")
