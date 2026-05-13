shader_type canvas_item;
// Uniform to access the screen texture
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
    // Get the color of the current object/layer
    vec4 overlay_sample = texture(TEXTURE, UV);
    // Get the color of what's already on the screen
    vec4 screen_sample = texture(screen_texture, SCREEN_UV);

    // Screen blend mode formula: 1 - (1 - background) * (1 - foreground)
    // The COLOR.rgb output is the final blended color
    COLOR.rgb = 1.0 - (1.0 - screen_sample.rgb) * (1.0 - overlay_sample.rgb);
    COLOR.a = overlay_sample.a; // Maintain the foreground's alpha
}
