extends Node2D

# TODO: global flag for allowing clicks of objects?
#       can use to determine if there should be a selection icon around tile
#       and if we should allow/process clicks

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$Grid2.build_grid(9,9)
	$Grid2.set_clickable_tiles()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func tile_clicked(posn: Vector2):
	#if can_click:
	print("Click from posn ", posn)
	
