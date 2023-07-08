extends ProgressBar

var timer_node: Timer

var sb: StyleBoxFlat

func _ready():
	sb = StyleBoxFlat.new()
	add_theme_stylebox_override("fill", sb)

func set_timer_node(tn):
	timer_node = tn

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	value = timer_node.time_left / timer_node.wait_time * 100.0
	
#	https://ask.godotengine.org/61430/how-make-progressbar-gradually-change-color-based-on-value
#	var color = lerp(Color.RED, Color.GREEN, ratio)
	var color = Color('fe4756')
	if (ratio > 0.75):
		color = Color('abc247') # maybe 48C247?
	elif (ratio > 0.5):
		color = Color('ebbe22')
	elif (ratio > 0.25):
		color = Color('fe9e49')

	sb.bg_color = color
	
# red fe4756  orange fe9e49  yellow ebbe22  green abc247
