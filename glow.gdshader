shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 0.0, 1.0); // Glow color
uniform float glow_size = 16.0; // Radius in pixels
uniform float glow_intensity = 4.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    
    float alpha = tex.a;
    float glow = 0.0;

    // Convert pixel size to UV offset
    vec2 pixel_size = TEXTURE_PIXEL_SIZE;

    // Sample around the pixel in a circle
    for (float x = -glow_size; x <= glow_size; x++) {
        for (float y = -glow_size; y <= glow_size; y++) {
            vec2 offset = vec2(x, y) * pixel_size;
            float dist = length(vec2(x, y));

            if (dist <= glow_size) {
                float sample_alpha = texture(TEXTURE, UV + offset).a;
                glow += sample_alpha * (1.0 - dist / glow_size);
            }
        }
    }

    glow = glow * glow_intensity / (glow_size * glow_size);

    // Only show glow outside the original sprite
    float outer_glow = glow * (1.0 - alpha);

    vec3 final_color = tex.rgb + glow_color.rgb * outer_glow;
    float final_alpha = max(alpha, outer_glow * glow_color.a);

    COLOR = vec4(final_color, final_alpha);
}