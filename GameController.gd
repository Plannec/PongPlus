extends Node2D

var player1: KinematicBody2D;
var player2: KinematicBody2D;
var ballScene: Resource;
var ball: KinematicBody2D;
var ballExplosionScene: Resource;

var player_left_score = 0;
var player_right_score = 0;

const Helper = preload("scripts/Helper.gd");

onready var sound = AudioStreamPlayer.new();
onready var helper_class = Helper.new();

# Score text
onready var player_left_score_text = $CenterContainer/GridContainer/LeftScore;
onready var player_right_score_text = $CenterContainer/GridContainer/RightScore;

func _ready():
	add_child(sound);
	
	player1 = $"Player";
	player2 = $"Player2";
	ballScene = load("res://Ball.tscn");
	ballExplosionScene = load("res://scenes/explosions/ball_destroy.tscn");
	spawn_ball();
	
func spawn_ball():
	ball = ballScene.instance();
	ball.connect("destroy", self, "_on_ball_destroy");
	
	add_child(ball);
	
func _on_ball_destroy(x_position: float):
	print("Death on ", x_position);
	
	var explosion = ballExplosionScene.instance() as Particles2D;
	
	# Left side? -> Score right player
	if (x_position < 64):
		print("Right player scored!");
		explosion.rotation_degrees = 180;
		
		print(explosion.position);
		
		player_right_score += 1;
		player_right_score_text.text = str(player_right_score);
	else:
		print("Left player scored!");
		
		player_left_score += 1;
		player_left_score_text.text = str(player_left_score);
	
	explosion.position = ball.position;
	explosion.emitting = true;
	explosion.restart();
	add_child(explosion);
		
	helper_class.play_sound(sound, "res://sounds/ball_destroy.wav");
	
	VisualServer.set_default_clear_color(Color(0.8, 0, 0, 1.0));
	yield(get_tree().create_timer(0.1), "timeout");
	VisualServer.set_default_clear_color(Color(0, 0, 0, 1.0));
	
	yield(get_tree().create_timer(1.0), "timeout");
	
	spawn_ball();

func _process(delta):
	pass;
