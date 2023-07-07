extends Node


var rng = RandomNumberGenerator.new()

enum TileType {
	RED,
	ORANGE,
	YELLOW,
	GREEN,
	BLUE,
	PURPLE
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
			print("num out of range: ", r)
			return TileType.PURPLE

