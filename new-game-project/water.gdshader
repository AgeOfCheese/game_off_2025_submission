shader_type canvas_item;
render_mode blend_mix;

uniform vec2 scroll_speed_1 = vec2(0.002,0.001);
uniform vec2 scroll_speed_2 = vec2(-0.015,0.025);

uniform float brightness = 0.8;
uniform float line_thickness = 0.08;

uniform vec4 water_color : source_color = vec4(0.1, 0.4, 0.7, 0.2); 
uniform float distortion_strength = 0.01;

uniform vec4 caustic_color : source_color = vec4(1.0, 1.0, 1.0, 0.5);

uniform float foam_threshold : hint_range(0.0, 1.0) = 0.85;
uniform float foam_brightness = 1;


uniform float pixelate_amount = 128;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void vertex() {
	// Called for every vertex the material is visible on.
}

float create_caustic_lines(float noise_value, float thickness)
{
	float centered_noise = noise_value - 0.5;
	float distance_from_line = abs(centered_noise);
	return 1.0 - smoothstep(0.0, thickness / 2.0, distance_from_line);
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	vec2 pixel_screen_uv = floor(SCREEN_UV * pixelate_amount) / pixelate_amount;
	
	vec2 pixel_uv = floor(UV * pixelate_amount) / pixelate_amount;
	
	vec2 uv1 = pixel_uv + (TIME * scroll_speed_1);
	vec2 uv2 = pixel_uv + (TIME * scroll_speed_2);
	
	float noise1 = texture(TEXTURE, uv1).r;
	float noise2 = texture(TEXTURE, uv2).r;
	
	vec2 distortion_offset = vec2(noise1 - 0.5, noise2 - 0.5) * distortion_strength;
	
	vec2 distorted_screen_uv = pixel_screen_uv + distortion_offset;
	
	vec4 background_color = texture(SCREEN_TEXTURE, distorted_screen_uv);
	float lines1 = create_caustic_lines(noise1, line_thickness);
	float lines2 = create_caustic_lines(noise2, line_thickness);
	float caustic_mask = max(lines1, lines2);
	vec4 final_color = background_color;
	
	final_color = mix(final_color, water_color, water_color.a);final_color = mix(final_color, caustic_color, caustic_mask * caustic_color.a);
	float raw_noise = max(noise1, noise2);
	float foam = smoothstep(foam_threshold, 1.0, raw_noise);
	
	final_color.rgb += foam * foam_brightness;
	
	COLOR = final_color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
