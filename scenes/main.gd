extends Node2D

# TODO: global flag for allowing clicks of objects?
#       can use to determine if there should be a selection icon around tile
#       and if we should allow/process clicks
var can_click:bool = true
var timer_time:float = 10
@export var min_timer_time: float = 3.0
@export var timer_decay: float = 0.1
var finger_swap: Array[Vector2] = []

enum Turn {PLAYER_TURN, FINGER_TURN}
var turn: Turn = Turn.PLAYER_TURN

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$Grid2.build_grid(9,9)
	$Grid2.set_clickable_tiles()
#	print("picked:", select_finger_swap())
	Events.connect("move_player_click", _on_tile_clicked)
	Events.connect("finger_click_complete", _on_fingerclick_complete)
	$TurnTimer.connect("timeout", _on_turntimer_timeout)
	$PlayerMoveTimer.connect("timeout", _on_playermovetimer_timeout)
	$FingerMoveTimer.connect("timeout", _on_fingermovetimer_timeout)
	
	$ProgressBar.set_timer_node($TurnTimer)
	# begin the game
	start_player_turn()


func _input(event):
	if can_click && turn == Turn.PLAYER_TURN:
		if event.is_action_pressed("player_movement_left"):
			# Get player posn
			var posn = $Grid2.player_posn
			if (posn.x > 0):
				_on_tile_clicked(Vector2(posn.x - 1, posn.y))
		elif event.is_action_pressed("player_movement_right"):
			# Get player posn
			var posn = $Grid2.player_posn
			if (posn.x < $Grid2.width - 1):
				_on_tile_clicked(Vector2(posn.x + 1, posn.y))
		elif event.is_action_pressed("player_movement_up"):
			# Get player posn
			var posn = $Grid2.player_posn
			if (posn.y > 0):
				_on_tile_clicked(Vector2(posn.x, posn.y - 1))
		elif event.is_action_pressed("player_movement_down"):
			# Get player posn
			var posn = $Grid2.player_posn
			if (posn.y < $Grid2.height - 1):
				_on_tile_clicked(Vector2(posn.x, posn.y + 1))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_player_turn():
	turn = Turn.PLAYER_TURN
	finger_swap = select_finger_swap()
	# TODO animate the tiles or smth
	$Swap1.position = $Grid2.global_posn_from_grid(finger_swap[0])
	$Swap2.position = $Grid2.global_posn_from_grid(finger_swap[1])
	$Swap1.play()
	$Swap2.play()
	$Swap1.visible = true
	$Swap2.visible = true
	print("finger will swap: ", finger_swap)
	can_click = true
	$Grid2.set_clickable_tiles()
	$TurnTimer.start(timer_time)
	timer_time = max(timer_time - timer_decay, min_timer_time)

func stop_player_turn():
	$TurnTimer.stop()
	turn = Turn.FINGER_TURN
	can_click = false
	$Grid2.disable_all_clickable_tiles()

func _on_turntimer_timeout():
	stop_player_turn()
	
	# Perform the finger swap
	if (finger_swap.size() == 2):
		$Finger.click_at_positions($Grid2.global_posn_from_grid(finger_swap[0]), $Grid2.global_posn_from_grid(finger_swap[1]))
	else:
		print_debug("ERROR wrong finger_swap size:", finger_swap)
		end_finger_turn()

func _on_fingerclick_complete():
	$Swap1.visible = false
	$Swap2.visible = false
	$Swap1.stop()
	$Swap2.stop()
	$Grid2.swap_tiles(finger_swap[0], finger_swap[1], true)
	$FingerMoveTimer.start()

func _on_fingermovetimer_timeout():
	end_finger_turn()

func end_finger_turn():
	# Perform all the matches
	await check_loop()
	start_player_turn()

func _on_tile_clicked(posn: Vector2):
	if can_click && turn == Turn.PLAYER_TURN:
#		print("Click from posn ", posn)
		#perform the swap now
		can_click = false
		$Grid2.disable_all_clickable_tiles()
		$Grid2.swap_player(posn)
		# use player timer to wait for the player swap to finish before doing other things
		$PlayerMoveTimer.start()

func _on_playermovetimer_timeout():
	# check for matches (TODO move this to just the finger swap)
#	await check_loop()
	# set back to true on animation completion (TODO check if player time is over / max moves have been made)
	if (turn == Turn.PLAYER_TURN):
		can_click = true
		$Grid2.set_clickable_tiles()

func check_loop():
	var cascades = -1
	while ($Grid2.check_for_matches()):
		cascades += 1
		AudioAutoload.play_pop(cascades)
		
		# TODO queue the bomb destruction? store in bombs field, and have main check that and queue this?
		if $Grid2.destroy_matches():
			await get_tree().create_timer(0.3).timeout
		while (true):
			var bomb_time = $Grid2.process_one_bomb()
			if (bomb_time.size() == 2):
				await get_tree().create_timer(bomb_time[0]).timeout
				$Grid2.destroy_matches()
				await get_tree().create_timer(bomb_time[1]).timeout
			else:
				if $Grid2.destroy_matches():
					await get_tree().create_timer(0.3).timeout
				break
		
		if $Grid2.clear_placing_bombs():
			# wait for bomb creation animation
			await get_tree().create_timer(1).timeout
		
#		await get_tree().create_timer(0.4).timeout
		$Grid2.drop_tiles()
#		$Grid2.disable_all_clickable_tiles()
		# wait a bit in between drops
		await get_tree().create_timer(0.7).timeout
	if cascades > 0:
		
		$VoiceAnimator.play_animation(cascades-1)

func select_finger_swap():
	# TODO do we need to be smarter about this to stop player from just corner camping?
	# Maybe adding bombs will be enough?
	var max_score = 0
	var best_move: Array[Vector2] = [Vector2(0, 0), Vector2(1, 0)]
	for h in $Grid2.height:
		for w in $Grid2.width:
			for d in 2:
				if w+d < $Grid2.width && h+1-d < $Grid2.height:
					var type_grid = $Grid2.clone_type_grid()
					var temp = type_grid[h+1-d][w+d]
					type_grid[h+1-d][w+d] = type_grid[h][w]
					type_grid[h][w] = temp
					var score = estimate_score(type_grid, $Grid2.width, $Grid2.height)
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

	
