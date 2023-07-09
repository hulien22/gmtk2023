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

func play_animation(line):
	if !has_died:
		current_line = line
		$VoiceLabel.text = lines[min(max(0,line), len(lines)-1)]
		play("ShowVoiceLine")

func play_audio():
	AudioAutoload.play_voice(current_line)

func _on_die():
	has_died = true
	play("Die")
