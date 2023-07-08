extends Node2D

# TODO: global flag for allowing clicks of objects?
#       can use to determine if there should be a selection icon around tile
#       and if we should allow/process clicks
var can_click:bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$Grid2.build_grid(9,9)
	$Grid2.set_clickable_tiles()
	print("picked:", select_finger_swap())
	Events.connect("move_player_click", _on_tile_clicked)
	$PlayerMoveTimer.connect("timeout", _on_playermovetimer_timeout)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_tile_clicked(posn: Vector2):
	if can_click:
		print("Click from posn ", posn)
		#perform the swap now
		can_click = false
		$Grid2.disable_all_clickable_tiles()
		$Grid2.swap_player(posn)
		# use player timer to wait for the player swap to finish before doing other things
		$PlayerMoveTimer.start()

func _on_playermovetimer_timeout():
	# check for matches (TODO move this to just the finger swap)
	await check_loop()
	# set back to true on animation completion (TODO check if player time is over / max moves have been made)
	can_click = true
	$Grid2.set_clickable_tiles()

func check_loop():
	while ($Grid2.check_for_matches()):
		$Grid2.drop_tiles()
		$Grid2.disable_all_clickable_tiles()
		# wait a bit in between drops
		await get_tree().create_timer(0.4).timeout

func select_finger_swap():
	var max_score = 0
	var best_move = [Vector2(0, 0), Vector2(1, 0)]
	for h in $Grid2.height-1:
		for w in $Grid2.width-1:
			for d in 2:
				var type_grid = $Grid2.clone_type_grid()
				var temp = type_grid[h+1-d][w+d]
				type_grid[h+1-d][w+d] = type_grid[h][w]
				type_grid[h][w] = temp
				var score = estimate_score(type_grid, 9, 9)
				if score >= max_score:
					max_score = score
					best_move = [Vector2(w, h), Vector2(w+d, h+1-d)]
	if max_score == 0:
		if $Grid2.player_posn.x > 0:
			best_move = [$Grid2.player_posn - Vector2(1, 0), $Grid2.player_posn]
		else:
			best_move = [$Grid2.player_posn, $Grid2.player_posn + Vector2(1, 0)]
	return best_move

#eimhin duplicating code for efficiency
func check_color_x(w, h, type_grid):
	if (w >= 2):
		if (type_grid[h][w-1] == type_grid[h][w] && type_grid[h][w-2] == type_grid[h][w]):
			return false
	return true
	
func check_color_y(w, h, type_grid):
	if (h >= 2):
		if (type_grid[h-1][w] == type_grid[h][w] && type_grid[h-2][w] == type_grid[h][w]):
			return false
	return true

func estimate_score(type_grid, width, height):
	var matches: Array[Vector2] = []
	for h in height:
		for w in width:
			if (!check_color_x(w, h, type_grid)):
				for i in 3:
					var p = Vector2(w-i, h)
					if (!matches.has(p)):
						matches.append(p)
			if (!check_color_y(w, h, type_grid)):
				for i in 3:
					var p = Vector2(w, h-i)
					if (!matches.has(p)):
						matches.append(p)
	return len(matches)

	
