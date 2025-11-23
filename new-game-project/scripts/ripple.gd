extends Area2D

@export var speed = 100
@export var push_force = 7500
@export var max_radius = 350
@export var friction = 0.1

@onready var collision_shape_2d = $CollisionShape2D

signal yap

# Called when the node enters the scene tree for the first time.
func _ready():
	#collision_shape_2d.shape.radius = 0 # Replace with function body.
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	collision_shape_2d.shape.radius += speed*delta
	
	var collided_bodies = get_overlapping_bodies()
	
	for body in collided_bodies:
		if body == get_parent():
			return
		if body is RigidBody2D:
			#print(body.linear_velocity)
			body.linear_velocity += ((body.global_position - global_position).normalized() * push_force * delta)/(collision_shape_2d.shape.radius + 1)
			
			body.linear_velocity-= body.linear_velocity*friction*delta
			
		if body is StaticBody2D:
			if get_parent():
				var new_ripple = get_parent().RIPPLE.instantiate()
				body.add_child(new_ripple)
	
	if collision_shape_2d.shape.radius >= max_radius:
		collision_shape_2d.shape.radius = 0 
		queue_free()
