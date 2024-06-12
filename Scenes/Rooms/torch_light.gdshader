shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec4 light_color : source_color;
uniform float intensity = 1.0;
uniform float flickeryness = 0.25;
uniform float flicker_speed = 3.0;

float atan2(in float y, in float x)
{
    return x == 0.0 ? sign(y)*PI/2.0 : atan(y, x);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 centered_coords = 2.0 * vec2(UV.x - 0.5, UV.y - 0.5);
	float angle = atan2(centered_coords.y, centered_coords.x);
	float angle_norm = (angle + (PI)) / (2.0 * PI);
	float d = distance(centered_coords, vec2(0.0, 0.0));
	
	float alpha = (1.0 - d);
	
	// Get the current screen UV coordinates
    vec2 screen_uv = SCREEN_UV;
    
    // Sample the screen texture at the current UV coordinates
    vec4 screen_color = texture(SCREEN_TEXTURE, screen_uv);
    
    // Output the screen color
    vec4 c1 = screen_color;
	
	float flicker_intensity = (1.0 - flickeryness) + (flickeryness * fract(sin(flicker_speed * TIME)));
	
	vec4 c2 = (intensity * flicker_intensity) * light_color;
	
	vec4 c3 = clamp(c1 + c2, 0.0, 1.0);
	
	alpha = clamp(alpha, 0.0, 1.0);
	
	COLOR = mix(c1, c3, alpha);
	
	
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
