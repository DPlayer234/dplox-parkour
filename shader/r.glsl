vec4 effect(vec4 vcolor, Image texture, vec2 texcoord, vec2 pixel_coords) {
	vec4 input = Texel(texture,texcoord)*vcolor;

	//float r = (input.r + input.g + input.b)/3;
	return vec4(input.r,0.0,0.0,input.a);
}
