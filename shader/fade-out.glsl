extern float player_x;
extern float player_y;

extern float screen_width;
extern float screen_height;

extern float x_mult;
extern float y_mult;

vec4 effect(vec4 vcolor, Image texture, vec2 texcoord, vec2 pixel_coords) {
	vec4 t = Texel(texture,texcoord);

	float x = ((pixel_coords.x/screen_width)-player_x)*x_mult;
	float y = ((pixel_coords.y/screen_height)-player_y)*y_mult;

	float dist = sqrt(x*x+y*y);

	return vec4(t.r,t.g,t.b,t.a-dist);
}
