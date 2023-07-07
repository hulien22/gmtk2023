extends Node2D

# POSITION is (column, row)
var posn: Vector2 = Vector2.ZERO
var is_player: bool = false
var type: Global.TileType

# Called when the node enters the scene tree for the first time.
func _ready():
	set_is_player(false)
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
		Global.TileType.EMPTY:
			# explode and delete?
			visible = false

func copy_from(tile):
	#posn = tile.posn
	set_is_player(tile.is_player)
	set_type(tile.type)
#	print("::", posn, is_player, type)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_is_player(enable:bool):
	is_player = enable
	if (is_player):
		$PlayerFace.visible = true
	else:
		$PlayerFace.visible = false

func set_clickable(enable: bool):
	#print(posn, enable)
	$Button.visible = enable
	$RichTextLabel.clear()
	$RichTextLabel.add_text(str(posn))

func _button_pressed():
	Events.emit_signal("move_player_click", posn)

func move(target):
	var tween: Tween = create_tween()
	tween.tween_property(self,"position",target, 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
