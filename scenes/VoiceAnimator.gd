extends AnimationPlayer

@export var lines: Array[String]

var has_died: bool

var current_line = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	has_died = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#func play_animation(line):
#	if !has_died:
#		current_line = line
#		$VoiceLabel.text = lines[min(max(0,line), len(lines)-1)]
#		play("ShowVoiceLine")

func play_animation(score, cascades):
	if !has_died:
		var val = -1
		if (score > 2000 || cascades > 8):
			val = 5
		elif (score > 1500 || cascades > 6):
			val = 4
		elif (score > 1000 || cascades > 5):
			val = 3
		elif (score > 750 || cascades > 4):
			val = 2
		elif (score > 500 || cascades > 3):
			val = 1
		elif (score > 250 || cascades > 2):
			val = 0
		
		if (val >= 0):
			$VoiceText.frame = val
			current_line = val
	#		$VoiceLabel.text = lines[min(max(0,line), len(lines)-1)]
			play("ShowVoiceLine")

func play_audio():
	AudioAutoload.play_voice(current_line)

func _on_die():
	has_died = true
	play("Die")
