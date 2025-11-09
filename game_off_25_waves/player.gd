extends CharacterBody2D

var start_time: float
var current_wave = 0
var base_y = -999999

var freq = 2
var amp = 2
var inv = 1


func _ready() -> void:
	start_time = Time.get_ticks_msec()/500.0

	
func _physics_process(delta: float) -> void:
	var cur_time = Time.get_ticks_msec()/500.0
	var wave_pos = cur_time-start_time
	$Trail.add_point(global_position)
	match(current_wave):
		0:
			velocity = Vector2(2,0)
		1:
			velocity = Vector2(2,inv*cos(wave_pos*freq)*5*amp)
		2:
			velocity = Vector2(2, inv*amp*6*(wave_pos/(2*freq) - floor(wave_pos/(2*freq) + 0.5)))
		3:
			velocity = Vector2(2, inv*amp*5*sign((sin(PI*wave_pos*freq))))
		4:
			if base_y<0:
				base_y = global_position.y
				print(base_y)
			if base_y>=0:
				velocity = Vector2(2,amp*fmod(wave_pos,1)*5)
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
	if event.is_action_pressed("amp_up"):
		amp+=1
	if event.is_action_pressed("amp_down"):
		amp-=1
	if event.is_action_released("amp_up") or event.is_action_released("amp_down"):
		amp =2
	if event.is_action_pressed("freq_up"):
		freq+=1
	if event.is_action_pressed("freq_down"):
		freq-=1
	if event.is_action_released("freq_up") or event.is_action_released("freq_down"):
		freq = 2
	if event.is_action_pressed("inv"):
		inv*=-1
	if event.is_action_released("inv"):
		inv*=-1
