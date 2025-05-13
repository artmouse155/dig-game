shader_type canvas_item;

uniform float animation_duration; // Duration of the animation in seconds
uniform float progress;
uniform bool flipped;

void fragment() {
	vec2 uv = UV;
    // Example animation: fade from black to white
	float uv_x = uv.x;

	if (flipped)
	{
		uv_x = 1.0 - uv_x;
	}

	float true_progress = max(min(uv_x + ((2.0 * progress) - 1.0), 1.0), 0.0);
    vec4 color = vec4(vec3(COLOR.xyz), true_progress);

    // Output the final color
    COLOR = color;
	/* Calculate animation progress from time
    float progress = min(TIME / animation_duration, 1.0);

	vec2 uv = UV;
	uv.y += wave_strength * sin((UV.x / wave_width) + (TIME*(2.0*PI) / wave_time)) / texture_height;
	vec4 color = texture(TEXTURE, uv);
	color = vec4(0.0,0.0,0.0,1.0);
	color.a = fract(UV.x + (TIME*(2.0*PI) / wave_time));
	COLOR = color;
	// Called for every pixel the material is visible on.
	*/
}