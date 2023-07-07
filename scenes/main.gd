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
	Events.connect("move_player_click", _on_tile_clicked)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_tile_clicked(posn: Vector2):
	if can_click:
		print("Click from posn ", posn)
		#perform the swap now
		can_click = false
		$Grid2.swap_player(posn)
	
	# set back to true on animation completion?
	can_click = true
	
