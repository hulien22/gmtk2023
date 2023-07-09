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
			new_tile.set_type_and_modifier(color, Global.Modifier.NONE)
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


var ordered_matches: Array[Vector2] = []
var matches: Dictionary = {}
var destroyed_matches: Dictionary = {}
var bombs: Array[Dictionary] = []
var placing_bombs: Dictionary = {}
func check_for_matches():
	ordered_matches.clear()
	matches.clear()
	destroyed_matches.clear()
	bombs.clear()
	placing_bombs.clear()

	# Get all tiles to destroy
	for h in height:
		for w in width:
			if (!check_color_x(tiles[h][w].posn, tiles[h][w].type)):
				for i in range(2, -1, -1):
					var p = tiles[h][w - i].posn
					if (add_to_matches_and_bombs(p)):
						ordered_matches.append(p)
			if (!check_color_y(tiles[h][w].posn, tiles[h][w].type)):
				for i in range(2, -1, -1):
					var p = tiles[h - i][w].posn
					if (add_to_matches_and_bombs(p)):
						ordered_matches.append(p)

	# Go through matches to find special matches
	# USE marked_for_destruction as marker if already processed for a bomb

	###
	# First check for long stretches 6+
	# search right then down
	for m in ordered_matches:
		for dir in [Vector2.RIGHT, Vector2.DOWN]:
			if (tiles[m.y][m.x].marked_for_destruction):
				break
			var c = count_matches_in_direction(m, matches, dir)
			if (c >= 6):
				var match_color = matches[m]
				var mid = floor((c-1) / 2)
				for i in c:
					var p = m + dir*i
					if (i == mid):
						print("PLACING COLOR BOMB ", p)
						tiles[p.y][p.x].set_type_and_modifier(match_color, Global.Modifier.BOMB)
						tiles[p.y][p.x].marked_for_destruction = true
						tiles[p.y][p.x].placing_bomb = true
						tiles[p.y][p.x].endpoints.clear()
						tiles[p.y][p.x].endpoints.append(m)
						tiles[p.y][p.x].endpoints.append(m + dir * (c - 1))
					else:
#						tiles[p.y][p.x].set_type_and_modifier(Global.TileType.EMPTY, Global.Modifier.NONE)
#						matches.erase(p)
						tiles[p.y][p.x].marked_for_destruction = true
						tiles[p.y][p.x].placing_bomb = false
	###
	# Second, check for Ts / Ls
	for m in ordered_matches:
		if (tiles[m.y][m.x].marked_for_destruction):
			continue
		var count_up = count_matches_in_direction(m, matches, Vector2.UP)
		var count_down = count_matches_in_direction(m, matches, Vector2.DOWN)
		var count_left = count_matches_in_direction(m, matches, Vector2.LEFT)
		var count_right = count_matches_in_direction(m, matches, Vector2.RIGHT)
		var col_count = count_up + count_down
		var row_count = count_left + count_right
		if (col_count >= 3 && row_count >= 3):
			var match_color = matches[m]
			# Add bomb
			print("PLACING DESTROYER BOMB ", m)
			tiles[m.y][m.x].set_type_and_modifier(match_color, Global.Modifier.DESTROYER_OF_EIGHT_TILES)
			tiles[m.y][m.x].marked_for_destruction = true
			tiles[m.y][m.x].placing_bomb = true
			tiles[m.y][m.x].endpoints.clear()
			# Remove other tiles
			var counts = [count_up, count_down, count_left, count_right]
			var dirs = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
			for x in 4:
				for i in range(1, counts[x]):
					var p = m + dirs[x]*i
					tiles[p.y][p.x].marked_for_destruction = true
					tiles[p.y][p.x].placing_bomb = false
				if (counts[x] > 1):
					tiles[m.y][m.x].endpoints.append(m + dirs[x] * (counts[x] - 1))
	###
	# Third, check for remaining long rows
	# (same code as for 6+)
	for m in ordered_matches:
		for dir in [Vector2.RIGHT, Vector2.DOWN]:
			if (tiles[m.y][m.x].marked_for_destruction):
				break
			var c = count_matches_in_direction(m, matches, dir)
			if (c >= 4):
				var match_color = matches[m]
				var mid = floor((c-1) / 2)
				for i in c:
					var p = m + dir*i
					if (i == mid):
						if (dir == Vector2.RIGHT):
							print("PLACING HORI BOMB ", p)
							tiles[p.y][p.x].set_type_and_modifier(match_color, Global.Modifier.HORIZONTAL)
						else:
							print("PLACING VERT BOMB ", p)
							tiles[p.y][p.x].set_type_and_modifier(match_color, Global.Modifier.VERTICAL)
						tiles[p.y][p.x].marked_for_destruction = true
						tiles[p.y][p.x].placing_bomb = true
						tiles[p.y][p.x].endpoints.clear()
						tiles[p.y][p.x].endpoints.append(m)
						tiles[p.y][p.x].endpoints.append(m + dir * (c - 1))
					else:
						tiles[p.y][p.x].marked_for_destruction = true
						tiles[p.y][p.x].placing_bomb = false

#	if (matches.size() > 0):
#		_debug_log_grid()
	
#	print(matches.size(), matches)
	return (matches.size() > 0)

func count_matches_in_direction(posn:Vector2, dict:Dictionary, dir:Vector2):
	var match_color = dict.get(posn)
	if (match_color == null):
		return 0
	var count = 1;
	while (true):
		var p = posn + dir*count
		if (p.x < 0 || p.x >= width || p.y < 0 || p.y >= height || tiles[p.y][p.x].marked_for_destruction):
			break
		var c = dict.get(p)
		if (c == match_color):
			count += 1
		else:
			break
	return count

# return number of seconds for the bomb animation to play
func process_one_bomb():
	if (bombs.is_empty()):
		return []
	var bomb = bombs.pop_front()
	bomb.tile.destroy_bomb_tile(global_posn_from_grid(bomb.posn), bomb.tile_type, bomb.bomb_type)
	if (bomb.bomb_type == Global.Modifier.BOMB):
		#iterate through all nodes and add all of that color to list to get destroyed
		#also keep track of any found bombs there and add them in here
		for h in height:
			for w in width:
				var p = tiles[h][w].posn
				# Only add in new tiles, so don't need to worry about new bombs (still in matches)
				if (tiles[h][w].type == bomb.tile_type):
					add_to_matches_and_bombs(p)
		return [0.8, 0.5]
	elif (bomb.bomb_type == Global.Modifier.DESTROYER_OF_EIGHT_TILES):
		for dir in [Vector2(-1,-1), Vector2(-1,0), Vector2(-1,1),
					Vector2(0,-1), Vector2(0,1),
					Vector2(1,-1), Vector2(1,0), Vector2(1,1)]:
			var p = bomb.posn + dir
			if (p.x >= 0 && p.x < width && p.y >= 0 && p.y < height):
				add_to_matches_and_bombs(p)
		return [0.8, 0.3]
	elif (bomb.bomb_type == Global.Modifier.VERTICAL):
		for i in height:
			var p = Vector2(bomb.posn.x, i)
			add_to_matches_and_bombs(p)
	elif (bomb.bomb_type == Global.Modifier.HORIZONTAL):
		for i in width:
			var p = Vector2(i, bomb.posn.y)
			add_to_matches_and_bombs(p)
	return [0.5, 0.3]

func add_to_matches_and_bombs(p: Vector2):
	if (!matches.has(p)):
		# Add to list to get destroyed
		matches[p] = tiles[p.y][p.x].type
		# TODO play animation? delay on timer?
		# or maybe just pass on to the bomb tile to trigger on its destroy animation
		if (tiles[p.y][p.x].modifier != Global.Modifier.NONE):
			bombs.append({
				posn = p,
				bomb_type = tiles[p.y][p.x].modifier,
				tile_type = tiles[p.y][p.x].type,
				tile = tiles[p.y][p.x]
			})
		return true
	return false

func clear_placing_bombs():
	for m in placing_bombs:
		tiles[m.y][m.x].placing_bomb = false
		tiles[m.y][m.x].marked_for_destruction = false
		tiles[m.y][m.x].make_bomb()

func destroy_matches():
	# Moves new matches to destroyed_matches, then plays their destroy animation
	var destroyed:bool = false
	for m in matches:
#		tiles[m.y][m.x].set_type_and_modifier(Global.TileType.EMPTY, Global.Modifier.NONE)
		if (!destroyed_matches.has(m)):
			if (!tiles[m.y][m.x].placing_bomb):
				tiles[m.y][m.x].play_destroy_anim(20, global_posn_from_grid(m))
				tiles[m.y][m.x].set_type_and_modifier(Global.TileType.EMPTY, Global.Modifier.NONE)
			else:
				# mark as placing_bombs for later, will animated their creation then
				placing_bombs[m] = true
			destroyed_matches[m] = true
			destroyed = true
	if destroyed:
		disable_all_clickable_tiles()
	return destroyed

func posn_from_grid(grid:Vector2):
	return grid * tile_spread

func global_posn_from_grid(grid:Vector2):
	return (grid * tile_spread) + global_position

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

func swap_tiles(a:Vector2, b:Vector2, do_move:bool):
#	print("swapping tiles ", a, b)
#	print(tiles[a.y][a.x].position, tiles[b.y][b.x].position)
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
	
	if do_move:
		tiles[a.y][a.x].move(posn_from_grid(Vector2(a.x,a.y)), Tween.TRANS_BOUNCE, 0.3)
		tiles[b.y][b.x].move(posn_from_grid(Vector2(b.x,b.y)), Tween.TRANS_BOUNCE, 0.3)
#	tiles[a.y][a.x].move(tile_b.position)
#	tiles[b.y][b.x].move(tile_a_position)

	# update player posn if we moved it
	if (a == player_posn):
		player_posn = b
	elif (b == player_posn):
		player_posn = a
#	print(tiles[a.y][a.x].position, tiles[b.y][b.x].position)
	await get_tree().create_timer(2).timeout

func swap_player(swap_posn:Vector2):
#	disable_all_clickable_tiles()
	swap_tiles(player_posn, swap_posn, true)
#	print(player_posn)

func drop_tiles():
#	var drops_per_column:Array[int] = []
	for w in width:
#		drops_per_column.append(0)
		var delete_count = 0
		# start from the bottom and go up
		for h in range(height-1, -1, -1):
			if (tiles[h][w].type == Global.TileType.EMPTY):
				tiles[h][w].destroy()
# Check if it has been destroyed, but isn't a new bomb
# if (destroyed_matches.has(Vector2(w,h)) && !placing_bombs.has(Vector2(w,h))):
				delete_count += 1
				# tile will delete itself after playing destruction animations?
				# tiles[h][w].queue_free()
			elif (delete_count > 0):
				# swap tiles but don't actually move them yet (ie keep them in same positions on screen for now)
				swap_tiles(Vector2(w,h), Vector2(w,h + delete_count), false)
		for i in delete_count:
			# add in new node above
			var new_tile = Tile.instantiate()
			new_tile.posn = Vector2(w, delete_count - i - 1)
			new_tile.position = posn_from_grid(Vector2(w, 0 - i - 1))
			new_tile.scale = Vector2(tile_size, tile_size)
			var color = Global.get_random_color()
			new_tile.set_type_and_modifier(color, Global.Modifier.NONE)
			add_child(new_tile)
			tiles[delete_count - i - 1][w] = new_tile

	for h in height:
		for w in width:
			tiles[h][w].move(posn_from_grid(Vector2(w,h)), Tween.TRANS_ELASTIC, 0.5)
#	print(player_posn)

func remove_deleted_tiles():
	pass
	
func clone_type_grid():
	var types_grid = [[]]
	for h in height:
		types_grid.push_back([])
		for l in width:
			types_grid[h].push_back(tiles[h][l].type)
	return types_grid

func _debug_log_grid():
	for h in height:
		var s = ""
		for w in width:
			match tiles[h][w].type:
				Global.TileType.RED:
					s += "R "
				Global.TileType.ORANGE:
					s += "O "
				Global.TileType.YELLOW:
					s += "Y "
				Global.TileType.GREEN:
					s += "G "
				Global.TileType.BLUE:
					s += "B "
				Global.TileType.PURPLE:
					s += "P "
		print(s)
