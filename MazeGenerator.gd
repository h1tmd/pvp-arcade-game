extends TileMap

const main_layer = 0
const normal_wall_atlas_coords = Vector2i(1, 1)
const walkable_atlas_coords = Vector2i(1, 4)
const SOURCE_ID = 0

@export var grid_size = 32
@export var start_coords = Vector2i(0, 0)

var height : int
var width : int
var directions = [
	Vector2i(0, -3), # North
	Vector2i(0, 3), # South
	Vector2i(3, 0), # East
	Vector2i(-3, 0), # West
]

func _ready():
	height = grid_size
	width = grid_size
	generate_border()
	generate_maze(start_coords)
	#split(9)


func _input(_event):
	# Press space to refresh maze
	if Input.is_action_just_pressed("ui_accept"):
		generate_border()
		generate_maze(start_coords)


func generate_border():
	var border = 3 - (grid_size % 3)
	for x in range (-1, width + border):
		for y in range(-1, height + border):
			set_cell(main_layer, Vector2i(x, y), SOURCE_ID, normal_wall_atlas_coords)


func place_path(pos1: Vector2i, pos2: Vector2i):
	# Places path around two points
	var topleft: Vector2i
	var bottomright: Vector2i
	# vertical
	if pos1.x == pos2.x:
		topleft = Vector2i(pos1.x, min(pos1.y, pos2.y))
		bottomright = Vector2i(pos1.x + 1, max(pos1.y, pos2.y) + 1)
	# horizontal
	else:
		topleft = Vector2i(min(pos1.x, pos2.x), pos1.y)
		bottomright = Vector2i(max(pos1.x, pos2.x) + 1, pos1.y + 1)
	for x in range(topleft.x, bottomright.x + 1):
		for y in range(topleft.y, bottomright.y + 1):
			set_cell(main_layer, Vector2i(x, y), SOURCE_ID, walkable_atlas_coords)


func can_move_to(current: Vector2i):
	# Returns true if it is within the maze
	return (
			current.x >= 0 and current.y >= 0 and
			current.x <= width and current.y <= height
	)


func generate_maze(start: Vector2i):
	var stack: Array[Vector2i] = [start]
	var visited = []
	while stack.size() > 0:
		var current = stack.pop_back() as Vector2i
		
		# add position to visited
		if current not in visited:
			visited.append(current)
		
		# Search all neighbors
		directions.shuffle()
		for pos in directions:
			var new_pos = current + pos
			# if new random position is new and not a wall
			if new_pos not in visited and can_move_to(new_pos):
				stack.append(current)
				stack.append(new_pos)
				place_path(current, new_pos)
				break


func split(num):
	# This function divides the maze into equal number of parts
	var dimension = grid_size
	var n = sqrt(num)
	var edge_length = dimension / n
	var subsquare = [0]
	for i in range(n):
		subsquare.append((i + 1) * edge_length)
	for i in range(len(subsquare) - 1):
		for j in range(len(subsquare) - 1):
			var tile = TileMap.new()
			tile.tile_set = load("res://tilemap.tres")
			for y in range(subsquare[i], subsquare[i + 1]):
				for x in range(subsquare[j], subsquare[j + 1]):
					var tile_atlas = get_cell_atlas_coords(main_layer, Vector2i(x, y))
					tile.set_cell(main_layer,Vector2i(x,y), SOURCE_ID, tile_atlas)
			get_parent().add_child.call_deferred(tile)
