shader_type canvas_item;

uniform float spin_speed = 0.1;
uniform int num_rays = 5;

float atan2(in float y, in float x)
{
    return x == 0.0 ? sign(y)*PI/2.0 : atan(y, x);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

float fancy_sin(in float x) {
	float inner_x = float(num_rays) * x * (2.0 * PI);
	inner_x = inner_x / 40.0;
	float s = sin((1.0 + abs(sin(TIME))) * inner_x) * sin(7.0 * inner_x) * sin(2.2 * inner_x) * sin(8.1 * inner_x) * sin(7.0 * inner_x);
	return clamp(s * 2.0, 0.0, 1.0);
}

void fragment() {
	
	
	float d = sqrt(((UV.x - 0.5) * (UV.x - 0.5)) + ((UV.y - 0.5) * (UV.y - 0.5)));
	vec2 centered_coords = 2.0 * vec2(UV.x - 0.5, UV.y - 0.5);
	float angle = atan2(centered_coords.y, centered_coords.x);
	float angle_norm = (angle + (PI)) / (2.0 * PI);
	d = distance(centered_coords, vec2(0.0, 0.0));
	//float angle2 = asin(UV.y / d);
	float spin = fract(angle_norm + (spin_speed * TIME));
	float alpha = (1.0 - d) * fancy_sin(spin);
	COLOR = vec4(1.0, 1.0, 1.0, alpha);
	//COLOR.a = angle_norm;
	//COLOR = vec4(1.0, UV.x + UV.y, 1.0, 1.0 - (2.0 * distance));
	//COLOR.a = 1.0;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
