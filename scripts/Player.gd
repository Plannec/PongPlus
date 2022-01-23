extends KinematicBody2D

# ui_up/down is left player
# ui_up2/down2 is right player
enum PlayerSide {
	RIGHT,
	LEFT
}

export(PlayerSide) var player_side = PlayerSide.RIGHT;
export var move_speed = 200;
export var margin = 128;

func _ready():
	# Place player on its side correct side.
	var position_left = 0;
	var position_right = get_viewport_rect().size.x;
	
	position.y = get_viewport_rect().size.y / 2;
	
	if (player_side == PlayerSide.RIGHT):
		position.x = position_right - margin;
	else:
		position.x = margin;


func _process(delta):
	var velocity = Vector2();
	if (player_side == PlayerSide.LEFT):
		if (Input.is_action_pressed("ui_up")):
			velocity.y -= move_speed;
		if (Input.is_action_pressed("ui_down")):
			velocity.y += move_speed;
			
	if (player_side == PlayerSide.RIGHT):
		if (Input.is_action_pressed("ui_up2")):
			velocity.y -= move_speed;
		if (Input.is_action_pressed("ui_down2")):
			velocity.y += move_speed;
		
	move_and_slide(velocity);
