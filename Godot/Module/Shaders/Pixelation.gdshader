shader_type spatial;
render_mode unshaded;

uniform sampler2D screen: hint_screen_texture;
uniform int pixel_size = 2;

void fragment() {
	float x = float(int(FRAGCOORD.x) % pixel_size);
	float y = float(int(FRAGCOORD.y) % pixel_size);
	
	x = FRAGCOORD.x + floor(float(pixel_size) / 2.0) - x;
	y = FRAGCOORD.y + floor(float(pixel_size) / 2.0) - y;
	
	ALBEDO = texture(screen, vec2(x, y) / VIEWPORT_SIZE).rgb;
}
