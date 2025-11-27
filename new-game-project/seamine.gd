extends RigidBody2D

@export var pull_force: float = 7500
@onready var friction = 0.1
@onready var anchor: Node2D = $"../../AnchorPoint"
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sparks: GPUParticles2D = $Sparks

func _physics_process(delta):
	var direction_to_anchor = (anchor.global_position - global_position)
	print(direction_to_anchor)
	print(delta)
	apply_central_force(direction_to_anchor * pull_force*delta-friction*direction_to_anchor*pull_force*delta)
	

func explode():
	sparks.emitting = true;
	await sparks.finished
	queue_free()
	
	


func _on_body_entered(body: Node) -> void:
	if body.get_class() == "RigidBody2D":
		explode()
		print("collided")
