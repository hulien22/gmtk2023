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
			new_tile.position = new_tile.posn * tile_spread
			new_tile.scale = Vector2(tile_size, tile_size)
			var color = Global.get_random_color()
			# TODO check that this doesn't form a match
			new_tile.set_type(color)
			add_child(new_tile)
			tiles[h].push_back(new_tile)
	
	# pick one tile to be the player
	var p_index = Global.rng.randi_range(0,height*length - 1)
	player_posn = Vector2(p_index / length,p_index % height)
	tiles[p_index / length][p_index % height].set_is_player()

func set_clickable_tiles():
	for h in height:
		for w in width:
			if (abs(player_posn.x - h) + abs(player_posn.y - w) == 1):
				tiles[h][w].set_clickable(true)
			else:
				tiles[h][w].set_clickable(false)
	
