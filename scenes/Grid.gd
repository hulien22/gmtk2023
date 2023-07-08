extends Node2D

@export var Tile: PackedScene

@export var tile_spread: float
@export var tile_size: float

var tiles = [[]]

# store player tile location - TODO want this to be a vector?
var player_posn:Vector2 = Vector2.ZERO

var height:int = 9
var width:int = 9

# Called when the node enters the scene tree for the first time.
func _ready():
	#build_grid(9,9)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func build_grid(height, length):
	tiles.clear()
	for h in height:
		tiles.push_back([])
		for l in length:
			var new_tile = Tile.instantiate()
			new_tile.posn = Vector2(l,h)
			new_tile.position = posn_from_grid(new_tile.posn)
			new_tile.scale = Vector2(tile_size, tile_size)
			var color = Global.get_random_color()
			while (!check_color(new_tile.posn, color)):
				color = Global.get_random_color()
			new_tile.set_type(color)
			add_child(new_tile)
			tiles[h].push_back(new_tile)
	
	# pick one tile to be the player
	var p_index = Global.rng.randi_range(0,height*length - 1)
	player_posn = Vector2(p_index % height, p_index / length)
	tiles[p_index / length][p_index % height].set_is_player(true)

func check_color_x(posn, type):
	if (posn.x >= 2):
		if (tiles[posn.y][posn.x-1].type == type && tiles[posn.y][posn.x-2].type == type):
			return false
	return true
func check_color_y(posn, type):
	if (posn.y >= 2):
		if (tiles[posn.y-1][posn.x].type == type && tiles[posn.y-2][posn.x].type == type):
			return false
	return true
	
func check_color(posn, type):
	if (check_color_x(posn, type)):
		return check_color_y(posn, type)

func check_for_matches():
	# Get all tiles to destroy
	var matches: Array[Vector2] = []
	for h in height:
		for w in width:
			if (!check_color_x(tiles[h][w].posn, tiles[h][w].type)):
				for i in 3:
					var p = tiles[h][w - i].posn
					if (!matches.has(p)):
						matches.append(p)
			if (!check_color_y(tiles[h][w].posn, tiles[h][w].type)):
				for i in 3:
					var p = tiles[h - i][w].posn
					if (!matches.has(p)):
						matches.append(p)

	# Go through matches to find special matches
	# TODO also need to check color here?
	for m in matches:
		var matches_col = 0
		var matches_row = 0
		for other in matches:
			if (other.x == m.x && abs(other.y - m.y) < 3):
				matches_col += 1
			if (other.y == m.y && abs(other.x - m.x) < 3):
				matches_row += 1
		print("col matches: ", matches_col, "row matches: ", matches_row)
	
	# Delete all the nodes
	for m in matches:
		tiles[m.y][m.x].set_type(Global.TileType.EMPTY)

func posn_from_grid(grid:Vector2):
	return grid * tile_spread

func set_clickable_tiles():
	for h in height:
		for w in width:
			if (abs(player_posn.y - h) + abs(player_posn.x - w) == 1):
				tiles[h][w].set_clickable(true)
			else:
				tiles[h][w].set_clickable(false)

func disable_all_clickable_tiles():
	for h in height:
		for w in width:
			tiles[h][w].set_clickable(false)

func swap_tiles(a:Vector2, b:Vector2):
	print("swapping tiles ", a, b)
	print(tiles[a.y][a.x].position, tiles[b.y][b.x].position)
#	var temp_tile_a = Tile.instantiate()
#	temp_tile_a.copy_from(tiles[a.y][a.x])
#	tiles[a.y][a.x].copy_from(tiles[b.y][b.x])
#	tiles[b.y][b.x].copy_from(temp_tile_a)
#	tiles[a.y][a.x].move(posn_from_grid(tiles[a.y][a.x].posn))
#	tiles[b.y][b.x].move(posn_from_grid(tiles[b.y][b.x].posn))
	
	var tile_a = tiles[a.y][a.x]
	var tile_b = tiles[b.y][b.x]
	tiles[a.y][a.x] = tile_b
	tiles[b.y][b.x] = tile_a
	tiles[a.y][a.x].posn = Vector2(a.x,a.y)
	tiles[b.y][b.x].posn = Vector2(b.x,b.y)
	
	tiles[a.y][a.x].move(posn_from_grid(Vector2(a.x,a.y)))
	tiles[b.y][b.x].move(posn_from_grid(Vector2(b.x,b.y)))
#	tiles[a.y][a.x].move(tile_b.position)
#	tiles[b.y][b.x].move(tile_a_position)

	# update player posn if we moved it
	if (a == player_posn):
		player_posn = b
	elif (b == player_posn):
		player_posn = a
	print(tiles[a.y][a.x].position, tiles[b.y][b.x].position)

func swap_player(swap_posn:Vector2):
	disable_all_clickable_tiles()
	#Play animation?
	
	swap_tiles(player_posn, swap_posn)
	print(player_posn)
	# check for matches
	check_for_matches()
	
	set_clickable_tiles()

func remove_deleted_tiles():
	pass
