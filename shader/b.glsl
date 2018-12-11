vec4 effect(vec4 vcolor, Image texture, vec2 texcoord, vec2 pixel_coords) {
	vec4 input = Texel(texture,texcoord)*vcolor;

	//float b = (input.r + input.g + input.b)/3;
	return vec4(0.0,input.g,input.b,input.a);
}
