shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0);

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float overlay_alpha = 1.0 - progress;
    // blend (hardcoded) darkest color from dither palette
    vec3 final_color = mix(tex.rgb, vec3(0.067,0.086,0.078), overlay_alpha);

    COLOR = vec4(final_color, tex.a);
}