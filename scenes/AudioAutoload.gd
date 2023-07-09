extends AudioStreamPlayer

@export var song: AudioStream
@export var pops: Array[AudioStream]
@export var voices: Array[AudioStream]
@export var destroyer: AudioStream
@export var knife: AudioStream
@export var bomb: AudioStream

var music_stopped: bool = false

func _ready():
	stream = song
	play()

func _on_finished():
	play()
	
func toggle_music():
	stream_paused = !stream_paused

func play_pop(cascades):
	if !stream_paused:
		$SoundEffect.stream = pops[min(max(0,cascades),len(pops)-1)]
		$SoundEffect.play()

func play_voice(cascades):
	if !stream_paused:
		$VoiceEffect.stream = voices[min(max(0,cascades),len(voices)-1)]
		$VoiceEffect.play()

func play_destroyer():
	if !stream_paused:
		$SoundEffect.stream = destroyer
		$SoundEffect.play()
