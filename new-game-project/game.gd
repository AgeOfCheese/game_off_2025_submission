extends Node2D

var r1
var sling

func _ready():
	r1 = Rock.new()
	r1.setup(50)
	r1.position = Vector2(100, 100)
	sling = preload("res://node_2d.tscn").instantiate()
	r1.lines.append([sling.get_node("a1").position, sling.get_node("a2").position])
	add_child(sling)
	add_child(r1)
	
func _process(dt):
	sling.update_rock(r1)
	
