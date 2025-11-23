extends Sprite2D

class_name Rock

const k = 0.01
const kpick = 0.011
const density = 10
const gravity = 0.5
const theta = 10
const hcam = 500
const iters = 40

var rad
var picked
var bypass
var curforce
var flying
var m
var vel
var vy
var y
var lines

func setup(r):
	rad = r
	scale = Vector2(r, r) * k
	texture = load("res://rock.png")
	picked = null
	curforce = 0
	m = density * r * r
	flying = false
	vel = Vector2.ZERO
	vy = 0
	y = 0
	lines = []
	
func _process(dt):
	if flying:
		var ax
		var ay
		if curforce.length() < 0.001:
			ay = -gravity
			ax = Vector2.ZERO
		else:
			var a = curforce / m
			ay = a.length() * sin(deg_to_rad(theta))
			ax = a * cos(deg_to_rad(theta))
		for i in range(iters):
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
				moveto(picked[0] + mpos - picked[1])
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
	
func moveto(newpos):
	var movevec = newpos - position
	var p1 = position
	var radvec = movevec.normalized() * rad
	var p2 = p1 + movevec + radvec
	for line in lines:
		var inter = Geometry2D.segment_intersects_segment(p1, p2, line[0], line[1])
		if inter != null:
			var unit = (line[1] - line[0]).normalized()
			var perp = Vector2(-unit.y, unit.x)
			if perp.dot(movevec) > 0:
				perp = -perp
			position = inter + perp * rad
			return
	position = newpos

func is_picked():
	return picked
