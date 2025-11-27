extends Area2D

@export var speed = 100
@export var push_force = 7500
@export var max_radius = 200
@export var friction = 0.1

@onready var collision_shape_2d = $CollisionShape2D



signal yap

# Called when the node enters the scene tree for the first time.
func _ready():
	collision_shape_2d.shape  = collision_shape_2d.shape.duplicate()
	collision_shape_2d.shape.radius = 0 # Replace with function body.
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	collision_shape_2d.shape.radius += speed*delta
	
	if collision_shape_2d.shape.radius >= max_radius:
		collision_shape_2d.shape.radius = 0 
		queue_free()
	
	var collided_bodies = get_overlapping_bodies()
	
	for body in collided_bodies:
		if body == get_parent():
			continue
		if body is RigidBody2D:
			#print(body.linear_velocity)
			body.linear_velocity += ((body.global_position - global_position).normalized() * push_force * delta)/(collision_shape_2d.shape.radius + 1)
			
			body.linear_velocity-= body.linear_velocity*friction*delta
			
	



func _on_body_entered(body: Node2D) -> void:
	if body == get_parent():
		return
	if body is StaticBody2D:
		if get_parent():
			var collision_point_finder = RayCast2D.new()
			collision_point_finder.enabled = true
			collision_point_finder.collide_with_areas = false
			
			collision_point_finder.target_position = to_local(body.global_position)
			
			var collision_point = body.position
			var space_state
			if not get_world_2d().direct_space_state:
				return
			else:
				space_state = get_world_2d().direct_space_state
			var query = PhysicsRayQueryParameters2D.create(collision_shape_2d.global_position, body.global_position)
			var result = space_state.intersect_ray(query)
			
			if result:
				print(result.position)
				collision_point = result.position
		
			var new_ripple = get_parent().RIPPLE.instantiate()
			new_ripple.max_radius = max_radius - collision_shape_2d.shape.radius
			body.add_child(new_ripple)
			new_ripple.global_position = collision_point
			
				
