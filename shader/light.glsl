#define THRESHOLD 0.8
#define SHADOW_DARKNESS 0.75

extern float LENGTH;
extern float X_STEP;
extern float Y_STEP;

/*#define LENGTH %lua_length%
#define X_STEP %lua_xstep%
#define Y_STEP %lua_ystep%*/

vec4 effect(vec4 vcolor, Image texture, vec2 texcoord, vec2 pixel_coords) {
	vec4 orig = Texel(texture,texcoord);

	if (orig.a < THRESHOLD) {
		vec2 coord = texcoord;
		float alpha = 0.0;

		for (float i=0.0; i<LENGTH; i+=Y_STEP) {

			vec4 pix = Texel(texture,coord);

			float darkness = pix.a*((LENGTH-i)/LENGTH);

			if (darkness > alpha) {
				alpha = darkness;
				if (pix.a > THRESHOLD) {
					break;
				}
			}
			else if (coord.x < 0.0 || coord.y < 0.0) break;

			coord.x += X_STEP;
			coord.y -= Y_STEP;
		}

		if (orig.a < alpha*SHADOW_DARKNESS) return vec4(vec3(orig),alpha*SHADOW_DARKNESS);
		else return orig;
	}
	else return orig;
}
