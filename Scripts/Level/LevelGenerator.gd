extends Node2D
class_name LevelGenerator

@export var width: int = 31
@export var height: int = 100
@export var path_width: int = 3

var grid: Array = []

func generate_level(seed_val: int):
	ERLogger.debug("Generating procedural level starting with seed: " + str(seed_val))
	seed(seed_val)
	grid.clear()
	
	for x in range(width):
		var col = []
		for y in range(height):
			col.append(TileRegistry.TileType.Wall)
		grid.append(col)
		
	var p1_x = width / 4
	carve_vertical_lane(p1_x)
	
	var p2_x = (width * 3) / 4
	carve_vertical_lane(p2_x)
	
	for y in range(path_width, height - path_width, 15):
		carve_horizontal_lane(p1_x, p2_x, y)
		
	add_obstacles()

func carve_vertical_lane(x_center: int):
	for y in range(height):
		for w in range(-path_width / 2, path_width / 2 + 1):
			var nx = x_center + w
			if nx > 0 and nx < width - 1:
				grid[nx][y] = TileRegistry.TileType.Floor

func carve_horizontal_lane(x_start: int, x_end: int, y_center: int):
	for x in range(x_start, x_end + 1):
		for w in range(-path_width / 2, path_width / 2 + 1):
			var ny = y_center + w
			if ny > 0 and ny < height - 1:
				grid[x][ny] = TileRegistry.TileType.Floor

func add_obstacles():
	for x in range(1, width - 1):
		for y in range(1, height - 1):
			if grid[x][y] == TileRegistry.TileType.Floor:
				if randf() < 0.10:
					grid[x][y] = TileRegistry.TileType.Plant if randf() < 0.5 else TileRegistry.TileType.River

func apply_to_tilemap_layer(tilemap_layer: TileMapLayer):
	for x in range(width):
		for y in range(height):
			var tile_val = grid[x][y]
			tilemap_layer.set_cell(Vector2i(x, y), tile_val, Vector2i(0, 0))
