extends AudioStreamPlayer

@export var song: AudioStream
@export var pops: Array[AudioStream]
@export var voices: Array[AudioStream]

var music_stopped: bool = false

func _ready():
	stream = song
	play()

func _on_finished():
	play()
	
func toggle_music():
	stream_paused = !stream_paused

func play_pop(cascades):
	$SoundEffect.stream = pops[cascades%len(pops)]
	$SoundEffect.play()

func play_voice(cascades):
	$VoiceEffect.stream = voices[min(max(0,cascades),len(voices)-1)]
	$VoiceEffect.play()
