extends Node2D


var r1

@onready var sling = $sling

const RIPPLE = preload("uid://dc4t7eecpc2ve")
const RIPPLE_SHADER = preload("uid://h42teciswj01")


func _ready():

	r1 = Rock.new()

	r1.setup(25)

	r1.position = Vector2(100, 100)

	#r1.lines.append([sling.get_node("a1").position, sling.get_node("a2").position])

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

	if r1.y < -50:

		r1.end_launch()

		var new_ripple = RIPPLE.instantiate()

		new_ripple.position = r1.global_position
		
		var new_ripple_effect = ColorRect.new()
		
		new_ripple_effect.material = RIPPLE_SHADER.duplicate()
		new_ripple_effect.global_position = new_ripple.global_position
		new_ripple_effect.size = Vector2(new_ripple.max_radius, new_ripple.max_radius)
		
		add_child(new_ripple_effect)
		add_child(new_ripple)
		


	



func _on_restart_button_pressed() -> void:

	pass # Replace with function body.
