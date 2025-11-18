extends Node2D

var rockpos = null
var rockrad = 10
var shoottick = 0
var curdt

func _process(dt):
	queue_redraw()
	curdt = dt
	
func shoot():
	#do some stuff
	shoottick = 0.5 # anim time
	
func _draw():
	if rockpos == null:
		if shoottick > 0:
			#anim
			shoottick -= curdt
		else:
			draw_line($a1.position, $a2.position, Color(0, 0, 0))
		
	
