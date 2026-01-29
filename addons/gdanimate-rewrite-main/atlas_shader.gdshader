shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

// Thanks GDShader for no mat4 in shader instance uniforms!
instance uniform vec4 color_multipliers_0 = vec4(1.0, 0.0, 0.0, 0.0);
instance uniform vec4 color_multipliers_1 = vec4(0.0, 1.0, 0.0, 0.0);
instance uniform vec4 color_multipliers_2 = vec4(0.0, 0.0, 1.0, 0.0);
instance uniform vec4 color_multipliers_3 = vec4(0.0, 0.0, 0.0, 1.0);
instance uniform vec4 color_offsets = vec4(0.0);

instance uniform int blend_mode : hint_enum(
	"ADD",
	"ALPHA",
	"DARKEN",
	"DIFFERENCE",
	"ERASE",
	"HARD LIGHT",
	"INVERT",
	"LAYER", // Not implemented, just per BTA
	"LIGHTEN",
	"MULTIPLY",
	"NORMAL",
	"OVERLAY",
	"SCREEN",
	"SHADER", // Not implemented, just per BTA
	"SUBTRACT"
) = 10;

// most from https://godotshaders.com/snippet/blending-modes/
vec3 multiply(vec3 base, vec3 blend){
	return base * blend;
}

vec3 screen(vec3 base, vec3 blend){
	return 1.0 - (1.0 - base) * (1.0 - blend);
}

vec3 darken(vec3 base, vec3 blend){
	return min(base, blend);
}

vec3 lighten(vec3 base, vec3 blend){
	return max(base, blend);
}

vec3 difference(vec3 base, vec3 blend){
	return abs(base - blend);
}

vec3 overlay(vec3 base, vec3 blend){
	vec3 limit = step(0.5, base);
	return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit);
}

vec3 add(vec3 base, vec3 blend) {
	return base + blend;
}

vec3 subtract(vec3 base, vec3 blend) {
	return base - blend;
}

vec3 invert(vec3 base) {
	return vec3(1.0) - base;
}

void fragment() {
	mat4 color_multipliers = mat4(
		color_multipliers_0,
		color_multipliers_1,
		color_multipliers_2,
		color_multipliers_3
	);
	COLOR = color_offsets + (COLOR * color_multipliers);

	if (blend_mode > -1) {
		vec4 screen_c = texture(SCREEN_TEXTURE, SCREEN_UV);
		if (blend_mode == 2) {
			COLOR.rgb = darken(COLOR.rgb, screen_c.rgb);
		} else if (blend_mode == 9) {
			COLOR.rgb = multiply(COLOR.rgb, screen_c.rgb);
		} else if (blend_mode == 8) {
			COLOR.rgb = lighten(COLOR.rgb, screen_c.rgb);
		} else if (blend_mode == 12) {
			COLOR.rgb = screen(COLOR.rgb, screen_c.rgb);
		} else if (blend_mode == 11) {
			COLOR.rgb = overlay(screen_c.rgb, COLOR.rgb);
		} else if (blend_mode == 5) {
			COLOR.rgb = overlay(COLOR.rgb, screen_c.rgb);
		} else if (blend_mode == 0) {
			COLOR.rgb = add(COLOR.rgb, screen_c.rgb);
		} else if (blend_mode == 14) {
			COLOR.rgb = subtract(screen_c.rgb, COLOR.rgb);
		} else if (blend_mode == 3) {
			COLOR.rgb = difference(COLOR.rgb, screen_c.rgb);
		} else if (blend_mode == 6) {
			COLOR.rgb = invert(screen_c.rgb);
		} else if (blend_mode == 1 || blend_mode == 4) { // adobe animate skill issue
			discard;
		}
	}
}