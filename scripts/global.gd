extends Node

var rng = RandomNumberGenerator.new()

enum TileType {
	RED,
	ORANGE,
	YELLOW,
	GREEN,
	BLUE,
	PURPLE,
	EMPTY # used for deleted tiles
}

const MAX_COLOR = 6

func get_random_color():
	var r = rng.randi_range(0, Global.MAX_COLOR - 1)
	match r:
		0:
			return TileType.RED
		1:
			return TileType.ORANGE
		2:
			return TileType.YELLOW
		3:
			return TileType.GREEN
		4:
			return TileType.BLUE
		5:
			return TileType.PURPLE
		_:
			print_debug("num out of range: ", r)
			return TileType.PURPLE

func get_index_from_type(t: TileType):
	match t:
		TileType.RED:
			return 0
		TileType.ORANGE:
			return 1
		TileType.YELLOW:
			return 2
		TileType.GREEN:
			return 3
		TileType.BLUE:
			return 4
		TileType.PURPLE:
			return 5
		TileType.EMPTY:
			return 6
	print_debug("unknown tiletype: ", t)
	return 0

enum Modifier {
	NONE,
	VERTICAL,
	HORIZONTAL,
	DESTROYER_OF_EIGHT_TILES,
	BOMB
}

func get_index_from_modifier(m: Modifier):
	match m:
		Modifier.NONE:
			return 0
		Modifier.VERTICAL:
			return 1
		Modifier.HORIZONTAL:
			return 2
		Modifier.DESTROYER_OF_EIGHT_TILES:
			return 3
		Modifier.BOMB:
			return 4
	print_debug("unknown modifier: ", m)
	return 0
