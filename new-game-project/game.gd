extends Node2D

var r1
var sling

func _ready():
	r1 = Rock.new()
	r1.setup(50)
	r1.position = Vector2(100, 100)
	sling = preload("res://node_2d.tscn").instantiate()
	#r1.lines.append([sling.get_node("a1").position, sling.get_node("a2").position])
	add_child(sling)
	add_child(r1)
	
func _process(dt):
	#print(r1.y)
	sling.update_rock(r1)
	if not r1.is_picked():
		var f = sling.get_force()
		if f.length() > 0.001:
			if not r1.flying:
				r1.start_launch()
		r1.apply_force(f)
	if r1.y < -100:
		r1.end_launch()
