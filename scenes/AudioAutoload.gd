extends AudioStreamPlayer

@export var song: AudioStream
@export var pops: Array[AudioStream]
@export var voices: Array[AudioStream]

func _ready():
	stream = song
	play()

func _on_finished():
	play()

func play_pop(cascades):
	$SoundEffect.stream = pops[cascades%len(pops)]
	$SoundEffect.play()

func play_voice(cascades):
	$VoiceEffect.stream = voices[min(cascades,len(voices))]
	$VoiceEffect.play()
