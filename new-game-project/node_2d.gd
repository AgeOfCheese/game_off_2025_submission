extends Node2D

var rockpos = null
var rockrad = 10
var vibtick = 0
var curdt
var side = 0

func _process(dt):
	queue_redraw()
	curdt = dt
	
func _draw():
	#print(side)
	if rockpos == null:
		draw_line($a1.position, $a2.position, Color(0, 0, 0))
		return
	var vec = ($a2.position - $a1.position).normalized()
	var perpvec = Vector2(vec.y, -vec.x)
	var dist = (rockpos - $a1.position).dot(vec)
	var perpdist = (rockpos - $a1.position).dot(perpvec)
	if (side == 0) and (dist < ($a2.position - $a1.position).length()) and (dist > 0):
		if (perpdist > 0) and (perpdist < rockrad):
			side = 1
		elif (perpdist < 0) and (perpdist > -rockrad):
			side = -1
	else:
		if side == 1:
			if perpdist > rockrad:
				side = 0
				vibtick = 0.5
		if side == -1:
			if perpdist < -rockrad:
				side = 0
				vibtick = 0.5
	if side == 0:
		if vibtick <= 0:
			draw_line($a1.position, $a2.position, Color(0, 0, 0))
		else:
			#anim
			vibtick -= curdt
	else:
		
		pass
			
func update_rock(r):
	rockpos = r.position
	rockrad = r.rad
	
func tanpoints(p1, p2, r):
	var l = p1.distance_to(p2)
	var ang = acos(r / l)
	var diff = p1 - p2
	var startang = atan2(diff.y, diff.x)
	var a1 = startang + ang
	var a2 = startang - ang
	return [p2 + Vector2(cos(a1), sin(a1)) * r, p2 + Vector2(cos(a2), sin(a2)) * r]
		
	
