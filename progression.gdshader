shader_type canvas_item;

uniform float radius;
uniform vec2 position;

// void vertex() {
// 	// Called for every vertex the material is visible on.
// }

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 effective_pos = vec2(1920, 1080)*(UV-0.5) + position;
	float dist = (effective_pos.x * effective_pos.x + effective_pos.y * effective_pos.y) - (radius * radius);
	float abs_dist = abs(dist);
	float ramp_to = dist > 0.0 ? 0.1 : 0.0;
	// multiplying by radius helps keep the line roughly the same thickness regardless of size
	float alpha = mix(1.0, ramp_to, clamp(abs_dist / (10.0 * radius), 0.0, 1.0));
	COLOR = vec4(0.8, 0.1, 0.1, alpha);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
