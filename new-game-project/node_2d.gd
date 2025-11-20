extends Node2D

var l0
const k = 100

var rockpos = null
var rockrad = 10
var vibtick = 0
var curdt
var side = 0
var force

func _ready():
	l0 = ($a2.position - $a1.position).length() * 0.8

func _process(dt):
	queue_redraw()
	curdt = dt
	
func _draw():
	#print(side)
	if rockpos == null:
		draw_line($a1.position, $a2.position, Color(0, 0, 0))
		force = Vector2.ZERO
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
			draw_line($a1.position, $a2.position, Color(0, 0, 0), 3)
		else:
			#anim
			vibtick -= curdt
		force = Vector2.ZERO
	else:
		var tanp1 = tanpoints($a1.position, rockpos, rockrad)
		var tanp2 = tanpoints($a2.position, rockpos, rockrad)
		var p1
		var p2
		if side == 1:
			
			var p1a1 = vecang(tanp1[0] - $a1.position)
			var p1a2 = vecang(tanp1[1] - $a1.position)
			var diff = p1a2 - p1a1
			if diff > 0:
				if diff < PI:
					p1 = tanp1[1]
				else:
					p1 = tanp1[0]
			else:
				if diff > -PI:
					p1 = tanp1[0]
				else:
					p1 = tanp1[1]
					
			var p2a1 = vecang(tanp2[0] - $a2.position)
			var p2a2 = vecang(tanp2[1] - $a2.position)
			diff = p2a2 - p2a1
			if diff > 0:
				if diff < PI:
					p2 = tanp2[0]
				else:
					p2 = tanp2[1]
			else:
				if diff > -PI:
					p2 = tanp2[1]
				else:
					p2 = tanp2[0]
		
		else:
			
			var p1a1 = vecang(tanp1[0] - $a1.position)
			var p1a2 = vecang(tanp1[1] - $a1.position)
			var diff = p1a2 - p1a1
			if diff > 0:
				if diff < PI:
					p1 = tanp1[0]
				else:
					p1 = tanp1[1]
			else:
				if diff > -PI:
					p1 = tanp1[1]
				else:
					p1 = tanp1[0]
					
			var p2a1 = vecang(tanp2[0] - $a2.position)
			var p2a2 = vecang(tanp2[1] - $a2.position)
			diff = p2a2 - p2a1
			if diff > 0:
				if diff < PI:
					p2 = tanp2[1]
				else:
					p2 = tanp2[0]
			else:
				if diff > -PI:
					p2 = tanp2[0]
				else:
					p2 = tanp2[1]
		
		draw_line($a1.position, p1, Color(0, 0, 0), 3)
		draw_line(p1, p2, Color(0, 0, 0), 3)
		draw_line($a2.position, p2, Color(0, 0, 0), 3)
		
		# Force calculation
		var v1 = $a1.position - p1
		var v2 = $a2.position - p2
		var unit_dir = (v1.normalized() + v2.normalized()).normalized()
		var l = v1.length() + v2.length() + (p2 - p1).length()
		force = unit_dir * (l - l0) * k
		
func update_rock(r):
	rockpos = r.position
	rockrad = r.rad * 0.9
	
func tanpoints(p1, p2, r):
	var l = p1.distance_to(p2)
	var ang = acos(r / l)
	var diff = p1 - p2
	var startang = atan2(diff.y, diff.x)
	var a1 = startang + ang
	var a2 = startang - ang
	return [p2 + Vector2(cos(a1), sin(a1)) * r, p2 + Vector2(cos(a2), sin(a2)) * r]

func vecang(v):
	return atan2(v.y, v.x)
	
func get_force():
	return force
