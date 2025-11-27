extends Node2D

var r1
@onready var sling = $sling

# --- New Code Starts Here ---
# Get a reference to the distortion shader's material
@onready var distortion_material: ShaderMaterial = $Node2D/DistortionLayer.material

# Define how many ripples can be on screen at once
const MAX_RIPPLES = 10
# Define how long each ripple lasts (in seconds)
const RIPPLE_DURATION = 2.5

# This array will hold our ripple data (x, y, start_time, is_active)
var ripple_pool: Array[Vector4] = []
# --- New Code Ends Here ---

# We'll need this to detect the *first* frame the rock hits
var r1_just_hit_water = false

func _ready():
	r1 = Rock.new()
	r1.setup(25)
	r1.position = Vector2(100, 100)
	add_child(r1)
	
	# --- New Code Starts Here ---
	# Initialize the ripple pool
	for i in MAX_RIPPLES:
		# (x, y, start_time, is_active)
		# is_active = 0.0 means the slot is free
		ripple_pool.append(Vector4(0.0, 0.0, 0.0, 0.0))
	# --- New Code Ends Here ---
	
func _process(dt):
	sling.update_rock(r1)
	if not r1.is_picked():
		var f = sling.get_force()
		if f.length() > 0.001:
			if not r1.flying:
				r1.start_launch()
		r1.apply_force(f)

	# --- Ripple Logic Starts Here ---
	
	# 1. Check for a new rock hit
	var water_level_y = -50 # Your water level
	
	if r1.y < water_level_y and r1.flying and not r1_just_hit_water:
		# Rock just hit the water!
		r1_just_hit_water = true
		r1.end_launch() # (You might want to call this on a timer instead)
		
		# Call our new function to create a ripple
		trigger_ripple_at(r1.global_position)
		
	elif r1.y > water_level_y:
		# Reset the flag if the rock is above water again
		r1_just_hit_water = false
		
	# 2. Update the ripple pool and send it to the shader
	update_ripple_pool()
	
	# --- Ripple Logic Ends Here ---


# This function finds a free slot in our pool and activates a new ripple
func trigger_ripple_at(world_position: Vector2):
	# Normalize position (0.0 to 1.0) and correct for aspect ratio
	var resolution: Vector2 = get_viewport_rect().size
	var normalized_pos: Vector2 = world_position / resolution
	normalized_pos.x *= resolution.x / resolution.y
	
	# Get the current time
	var current_time: float = Time.get_ticks_msec() / 1000.0
	
	# Find an inactive ripple slot
	for i in range(MAX_RIPPLES):
		if ripple_pool[i].w == 0.0: # if is_active == 0.0
			ripple_pool[i] = Vector4(normalized_pos.x, normalized_pos.y, current_time, 1.0)
			break # Stop after finding one slot

# This function runs every frame
func update_ripple_pool():
	var current_time: float = Time.get_ticks_msec() / 1000.0
	var data_for_shader: Array[Vector4] = []
	
	# Loop through the pool
	for i in range(MAX_RIPPLES):
		var ripple = ripple_pool[i]
		
		if ripple.w == 1.0: # if this ripple is active
			var time_alive = current_time - ripple.z
			
			if time_alive > RIPPLE_DURATION:
				# Ripple is old, deactivate it
				ripple.w = 0.0
			
			ripple_pool[i] = ripple # Update the pool
			
		data_for_shader.append(ripple_pool[i])
		
	# Send the entire array to the shader
	if distortion_material:
		distortion_material.set_shader_parameter("rock_ripples", data_for_shader)
