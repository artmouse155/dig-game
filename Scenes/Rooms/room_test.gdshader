shader_type canvas_item;

uniform vec2 pixel_resolution = vec2(40, 40);
uniform vec2 tile_resolution = vec2(16, 16);

uniform vec2 light_rect_pixel_center = vec2(20, 20);

//Ranges from (0,0) to (1,1).
uniform vec2 tile_offset = vec2(0.0, 0.0);

uniform float light_radius = 9.0;

//inside of light_radius
uniform float light_edge_size = 3.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	//vec2 new_tile_offset = fract(vec2(1.0, 1.0) * TIME);
	vec2 new_tile_offset = fract(tile_offset);
	
	float alpha = 0.0;
	vec2 pixel_tile_resolution = (pixel_resolution / tile_resolution);
	vec2 grid_cor = floor((UV * pixel_tile_resolution) + new_tile_offset);
	
	//vec2 light_rect_pixel_center = pixel_resolution / 2.0;
	vec2 grid_cor_pixel_center = tile_resolution * ((grid_cor - new_tile_offset) + vec2(0.5, 0.5));
	
	float dist_from_center = distance(light_rect_pixel_center, grid_cor_pixel_center);
	alpha = clamp((dist_from_center - ((light_radius - light_edge_size) * tile_resolution.x)) / (tile_resolution.x * float(light_edge_size)), 0.0, 1.0);
	
	/*
	if (mod(grid_cor.x, 2.0) == 1.0)
	{
		alpha = 1.0;
		
		if (mod(grid_cor.y, 2.0) == 1.0)
	{
		alpha = 0.0;
	}
	}
	
	else if (mod(grid_cor.y, 2.0) == 1.0)
	{
		alpha = 1.0;
	}
	*/
	
	COLOR = vec4(0.0, 0.0, 0.0, alpha);
	COLOR = vec4(1.0, 1.0, 1.0, alpha);
	

}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
