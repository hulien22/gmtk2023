extends ProgressBar

var timer_node: Timer

func set_timer_node(tn):
	timer_node = tn

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	value = timer_node.time_left / timer_node.wait_time * 100.0

