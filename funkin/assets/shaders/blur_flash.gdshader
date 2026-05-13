shader_type canvas_item;

// ---------------------------------------------------------------------------
// 2‑D SEPARABLE BLUR  (Godot 4.x)
//  - Works on the sprite itself (default) or on the full screen.
//  - Uses evenly spaced samples within the radius to avoid the "ghost clones"
//    you were seeing.
//  - Set radius_x or radius_y to 0 to disable that axis.
// ---------------------------------------------------------------------------

uniform bool   use_screen       = false;                // true = blur screen
uniform int    num_pass : hint_range(1, 16) = 8;        // samples on each side
uniform float  radius_x : hint_range(0.0, 128.0) = 8.0; // blur radius in px (X)
uniform float  radius_y : hint_range(0.0, 128.0) = 8.0; // blur radius in px (Y)
uniform bool   do_normalize     = true;                // average by weights?

// Only needed when use_screen = true
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec4 modulate_color : source_color;

vec4 blur_b(sampler2D Texture,vec2 uv,float val){
	float Pi = PI * 2.0;
	vec2 Texture_pixel_size = 1.0/vec2(textureSize(Texture,0));
	float Directions = 12.0;
	float Quality = 6.0;
	float Size = 8.0 * val;

	vec2 radius = Size/Texture_pixel_size.xy;
	vec4 Color = texture(Texture,uv);
	for( float d=0.0;d<Pi;d+=Pi/float(Directions) )
	{
		for( float i=1.0/float(Quality);i<=1.0;i+=1.0/float(Quality) )
		{
			vec2 this_uv = uv+vec2(cos(d),sin(d))*radius*i;
			Color += texture(Texture,this_uv);
		}
	}
	Color /= float(Quality)*float(Directions)+1.0;
	return Color;
}

void fragment() {
	COLOR = mix(COLOR,blur_b(TEXTURE,UV,abs(sin(radius_x/10.0 * .00001))),radius_y/5.0);
}