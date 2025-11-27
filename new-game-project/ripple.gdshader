shader_type canvas_item;

// Inspector uniforms
uniform float nsize : hint_range(0.0, 20.0) = 5.0;
uniform float nstrenght : hint_range(0.0, 5.0) = 1.0;
uniform float rippleSpeed : hint_range(0.0, 30.0) = 10.0;
uniform float rippleFreq : hint_range(0.0, 50.0) = 20.0;
uniform float ripple_size : hint_range(0.1, 2.0) = 0.8;
uniform float dropSize : hint_range(0.1, 2.0) = 0.7;
uniform float tile = 2.0;

// Uniforms from GDScript
uniform vec4 mouse_data = vec4(0.0, 0.0, 0.0, 0.0);
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// --- NEW UNIFORM ---
uniform vec4 rock_ripples[10];

// --- THIS IS THE FIX ---
// PI is a built-in constant in Godot 4, no need to declare it.
// const float PI = 3.14159265359; <-- This line was removed

float hash(float n) {
	return fract(sin(dot(vec2(n,n), vec2(12.9898,78.233))) * 43758.5453);
}

// This function now generates mouse ripples AND rock ripples
float brush(vec2 uv, float tile_param) {
	uv *= tile_param;
	
	// 1. Mouse Ripple (same as before)
	float mouseRipple;
	if(mouse_data.z > 0.5) {
		vec2 mPos = mouse_data.xy;
		mPos *= tile_param;
		float l = 1.0 - length(uv - mPos);
		mouseRipple = smoothstep(ripple_size, 1.0, l);
	} else {
		mouseRipple = 0.0;
	}
	
	// 2. Rock Ripples (replaces the old 'dropRipple' loop)
	float rockRipples = 0.0;
	const float ripple_duration = 2.5; // Must match RIPPLE_DURATION in script
	
	// Loop through our ripple pool array
	for (int i = 0; i < 10; i++) { // Must match MAX_RIPPLES
		
		if (rock_ripples[i].w > 0.5) { // if ripple is active
			
			vec2 rPos = rock_ripples[i].xy; // Get normalized position
			rPos *= tile_param; // Scale to tile space
			float startTime = rock_ripples[i].z;
			
			float time_alive = TIME - startTime;

			if (time_alive > 0.0 && time_alive < ripple_duration) {
				
				float rl = 1.0 - length(uv - rPos);
				float fTime = time_alive / ripple_duration; // Normalized fade time
				
				float rRipple = sin(rl*rippleFreq + time_alive*rippleSpeed)*0.5+0.5;
				float rB = smoothstep((1.0 - fTime)*dropSize, 1.0, rl);
				
				rockRipples += rB*rRipple*(1.0 - fTime);
			}
		}
	}
	
	return rockRipples + mouseRipple;
}

// This calculates the surface normal
vec3 calculateNormals(vec2 uv, float tile_param, vec2 resolution) {
	float offsetX = nsize / resolution.x;
	float offsetY = nsize / resolution.y;
	
	vec2 ovX = vec2(offsetX, 0.0);
	vec2 ovY = vec2(0.0, offsetY);
	
	float X = (brush(uv - ovX, tile_param) - brush(uv + ovX, tile_param)) * nstrenght;
	float Y = (brush(uv - ovY, tile_param) - brush(uv + ovY, tile_param)) * nstrenght;
	float Z = brush(uv, tile_param);
	
	return vec3(X, Y, Z);
}

// Fragment shader
void fragment() {
	vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;
	float ratio = resolution.x / resolution.y;
	
	vec2 uvR = SCREEN_UV;
	uvR.x *= ratio;
	
	vec3 n = calculateNormals(uvR, tile, resolution);
	
	vec2 distortion_offset = n.xy * (nstrenght / resolution);
	vec2 distorted_uv = SCREEN_UV + distortion_offset;
	
	vec4 original_color = texture(screen_texture, distorted_uv);
	
	// Masking
	float maskX = sin(SCREEN_UV.x * PI);
	float maskY = sin(SCREEN_UV.y * PI);
	float mask = smoothstep(0.3, 0.0, maskX * maskY);
	
	COLOR = mix(original_color, vec4(0.5, 0.5, 1.0, 1.0), mask);
}