extends Node2D

var r1
var sling

func _ready():
	r1 = Rock.new()
	r1.setup(50)
	r1.position = Vector2(100, 100)
	sling = preload("res://node_2d.tscn").instantiate()
	add_child(sling)
	add_child(r1)
	
	
