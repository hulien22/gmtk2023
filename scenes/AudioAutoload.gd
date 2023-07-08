extends AudioStreamPlayer

@export var song: AudioStream
@export var pops: Array[AudioStream]

func _ready():
	stream = song
	play()

func _on_finished():
	play()

func play_pop(cascades):
	$SoundEffect.stream = pops[cascades%len(pops)]
	$SoundEffect.play()
