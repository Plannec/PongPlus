extends KinematicBody2D

export var speed = 200;
export var multiplier = 1.25;
export var speed_limit = 750;
export var respect_limit = true;

onready var particles = $Particles2D;

# 1  = left to right
# -1 = right to left
var direction = Vector2(0, 0);
var angle = 0;
var sound = AudioStreamPlayer.new();

signal destroy(x_position)

# Called when the node enters the scene tree for the first time.
func _ready():
	sound.connect("finished", self, "_on_sound_finished");
	add_child(sound);
	
	position = get_viewport_rect().size / 2;
	
	# Wait before throwing into random direction.
	yield(get_tree().create_timer(1.0), "timeout");
	particles.emitting = true;
	direction = Vector2([-1, 1][randi() % 2], 0);
	
func _process(delta):
	# Hit left side?
	if (position.x < 1 || (get_viewport_rect().size.x - position.x) < 1):
		emit_signal("destroy", position.x);
		queue_free();
		
	# Hit ground?
	if (position.y < 0):
		position.y = 0.1;
		play_ground_sound();
		angle = 45;
	# Hit ceiling?
	if (position.y > get_viewport_rect().size.y):
		position.y = get_viewport_rect().size.y - 0.1;
		play_ground_sound();
		angle = -45;
		
	var final_move = Vector2();
	
	final_move.x = clamp(speed * multiplier, 0, speed_limit) * direction.x;
	
	if (angle != 0):
		final_move.y = angle;
	
	move_and_slide(final_move);

func play_sound(file: String):
	var rng = RandomNumberGenerator.new();
	rng.randomize();
	var pitch = rng.randf_range(0.6, 1);
	
	sound.stream = load(file);
	sound.volume_db = 1;
	sound.pitch_scale = pitch;
	
	print("Play ", file, " with pitch ", pitch);
	sound.play();

func play_ground_sound():
	play_sound("res://sounds/ball_wall.wav");
	
func play_random_sound():
	var rng = RandomNumberGenerator.new();
	rng.randomize();
	var path = "res://sounds/ball" + str(rng.randi_range(1, 3)) + ".wav";
	
	play_sound(path);
	
func _on_sound_finished():
	sound.stop();
	
func reflect(body: KinematicBody2D):
	if (body == null):
		pass;
	else:
		var reflection = (self.position.y - body.position.y) / 128;
		reflection *= 10;
		if (reflection > 0):
			angle = 45 * reflection;
		elif (reflection < 0):
			angle = -45 * -reflection;
			
		print("Reflection: ", reflection);

func _on_Area2D_body_entered(body):
	if (respect_limit):
		if (speed < speed_limit):
			# Change position
			speed *= multiplier;
			print("Hit detected -> Change speed to ", speed);
	else:
		speed *= multiplier;
		
	# Determine reflection
	reflect(body);
	
	direction.x *= -1;
	
	var amount = int((speed / speed_limit) * 100);
	print("Amount: " + str(amount));
	particles.amount = amount;
	(particles.process_material as ParticlesMaterial).direction.x = direction.x;
	
	var hue = sin(speed / speed_limit);
	print("Hue: " + str(hue));
	(particles.process_material as ParticlesMaterial).hue_variation = hue;
	
	play_random_sound();
