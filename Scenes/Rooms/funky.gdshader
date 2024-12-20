shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec2 box_size;
uniform float swirl_amount = 1.0;

float atan2(in float y, in float x)
{
    return x == 0.0 ? sign(y)*PI/2.0 : atan(y, x);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 BOX_PIXEL_SIZE = TEXTURE_PIXEL_SIZE * (1.0 / box_size);

	vec2 centered_coords = 2.0 * vec2(UV.x - 0.5, UV.y - 0.5);
	float angle = atan2(centered_coords.y, centered_coords.x);
	float angle_norm = (angle + (PI)) / (2.0 * PI);
	float d = distance(centered_coords, vec2(0.0, 0.0));

	float dist_from_wall = max(abs(centered_coords.x), abs(centered_coords.y));
	//dist_from_wall = abs(centered_coords.x);
	float new_angle = (swirl_amount * (1.0 - dist_from_wall)) + angle;

	vec2 uv_to_test = 0.5 * ((d * vec2(cos(new_angle), sin(new_angle))) + 1.0);
	uv_to_test = UV + (.1 * d);
	vec2 screen_uv = SCREEN_UV;
	screen_uv = SCREEN_UV + ((uv_to_test - UV) * (SCREEN_PIXEL_SIZE / BOX_PIXEL_SIZE));
	vec4 screen_color = texture(SCREEN_TEXTURE, screen_uv);

	COLOR = screen_color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
