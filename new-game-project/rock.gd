extends Sprite2D

class_name Rock

const k = 0.01
const kpick = 0.011
const density = 10
const gravity = 10
const theta = 45
const hcam = 10

var rad
var picked
var bypass
var curforce
var flying
var m
var vel
var vy
var y

func setup(r):
	rad = r
	scale = Vector2(r, r) * k
	texture = load("res://rock.png")
	picked = null
	curforce = 0
	m = density * r * r
	flying = false
	
func _process(dt):
	if flying:
		var a = curforce / m
		var ay = a.length() * sin(deg_to_rad(theta))
		var ax = a * cos(deg_to_rad(theta))
		vel += ax * dt
		vy += ay * dt
		position += vel * dt
		y += vy * dt
		updatesize()
	else:
		vel = Vector2.ZERO
		vy = 0
		y = 0
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if bypass:
				return
			var mpos = get_global_mouse_position()
			if (picked == null):
				if mpos.distance_to(position) < rad:
					picked = [position, mpos]
					scale = Vector2(rad, rad) * kpick
				else:
					bypass = true
			if picked != null:
				position = picked[0] + mpos - picked[1]
		else:
			bypass = false
			if not (picked == null):
				picked = null
				scale = Vector2(rad, rad) * k
			
func apply_force(f):
	curforce = f
	
func start_launch():
	flying = true
	
func end_launch():
	flying = false
	vel = Vector2.ZERO
	vy = 0
	y = 0
	updatesize()

func updatesize():
	scale = Vector2(rad, rad) * k * hcam / (hcam - y)
