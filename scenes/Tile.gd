extends Node2D

# POSITION is (column, row)
var posn: Vector2 = Vector2.ZERO
var is_player: bool = false
var type: Global.TileType

# Called when the node enters the scene tree for the first time.
func _ready():
	if (is_player):
		$PlayerFace.visible = true
	else:
		$PlayerFace.visible = false
	$Button.pressed.connect(self._button_pressed)

func set_type(t: Global.TileType):
	type = t
	match t:
		Global.TileType.RED:
			$ColorRect.color = Color.RED
		Global.TileType.ORANGE:
			$ColorRect.color = Color.ORANGE
		Global.TileType.YELLOW:
			$ColorRect.color = Color.YELLOW
		Global.TileType.GREEN:
			$ColorRect.color = Color.GREEN
		Global.TileType.BLUE:
			$ColorRect.color = Color.BLUE
		Global.TileType.PURPLE:
			$ColorRect.color = Color.PURPLE
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_is_player():
	is_player = true
	$PlayerFace.visible = true

func set_clickable(enable: bool):
	print(posn, enable)
	$Button.visible = enable

func _button_pressed():
	pass
