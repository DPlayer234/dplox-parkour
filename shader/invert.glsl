vec4 effect(vec4 vcolor, Image texture, vec2 texcoord, vec2 pixel_coords) {
	vec4 orig = vcolor*Texel(texture,texcoord);
	return vec4(vec3(1.0)-vec3(orig),orig.a);
}
