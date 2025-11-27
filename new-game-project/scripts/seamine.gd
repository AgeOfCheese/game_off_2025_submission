extends RigidBody2D

@export var pull_force: float = 100.0
@onready var anchor: Node2D = $Anchor
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sparks: GPUParticles2D = $Sparks

func _physics_process(delta):
	var direction_to_anchor = (anchor.global_position - global_position).normalized()
	apply_central_force(direction_to_anchor * pull_force)

func _on_body_entered(body):
	if body.is_in_group("Duck"):
		explode()
func explode():
	sprite.visible = false
	sparks.emitting = true;
	
