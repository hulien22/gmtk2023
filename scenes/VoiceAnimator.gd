extends AnimationPlayer

@export var lines: Array[String]

var current_line = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func play_animation(line):
	current_line = line
	$VoiceLabel.text = lines[min(max(0,line), len(lines)-1)]
	play("ShowVoiceLine")

func play_audio():
	AudioAutoload.play_voice(current_line)
