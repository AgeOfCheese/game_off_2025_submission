extends CharacterBody2D

var start_time: float
var current_wave = 0
var base_y = -999999
func _ready() -> void:
	start_time = Time.get_ticks_msec()/500.0

	
func _physics_process(delta: float) -> void:
	var cur_time = Time.get_ticks_msec()/500.0
	var wave_pos = cur_time-start_time
	match(current_wave):
		0:
			velocity = Vector2(2,0)
		1:
			velocity = Vector2(2,cos(wave_pos)*5)
		4:
			if base_y<0:
				base_y = global_position.y
				print(base_y)
			if base_y>=0:
				velocity = Vector2(2,fmod(wave_pos,1)*5)
				if abs(velocity.y) <= 0.25:
					print(1)
					global_position.y = base_y
			
	velocity.y*=-1
	move_and_collide(velocity)
	
func _unhandled_input(event: InputEvent) -> void:

	if event.is_action_pressed("sin_wave"):
		current_wave = 1
		base_y = -999999
	if event.is_action_pressed("trig_wave"):
		current_wave = 2
		base_y = -999999
	if event.is_action_pressed("square_wave"):
		current_wave = 3
		base_y = -999999
	if event.is_action_pressed("saw_wave"):
		current_wave = 4
		base_y = -999999
		
