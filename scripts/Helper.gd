extends Node

# Plays target sound at random pitch.
func play_sound(sound: AudioStreamPlayer, file: String):
	var rng = RandomNumberGenerator.new();
	rng.randomize();
	var pitch = rng.randf_range(0.6, 1);
	
	sound.stream = load(file);
	sound.volume_db = 1;
	sound.pitch_scale = pitch;
	
	print("Play ", file, " with pitch ", pitch);
	sound.play();
