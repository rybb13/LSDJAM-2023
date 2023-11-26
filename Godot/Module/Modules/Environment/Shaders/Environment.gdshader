shader_type spatial;
render_mode unshaded;

uniform sampler2D sprite_sheet: filter_nearest, source_color;
uniform vec2 scale = vec2(1.0);
uniform uint frames = 8;
uniform float speed = 1.0;
uniform float size = 10.0;
uniform vec3 tint: source_color = vec3(1.0);
uniform float brightness: hint_range(0.0, 1.0) = 1.0;
uniform float contrast: hint_range(0.0, 1.0) = 1.0;

vec2 sprite_anim(vec2 uv, float anim_speed, uint anim_frames) {
	return fract(uv * scale * float(anim_frames)) / vec2(float(anim_frames), 1.0) + vec2(floor(fract(TIME * anim_speed) * float(anim_frames)) / float(anim_frames), 0.0);
}

void fragment() {
	vec4 projected_coords = INV_VIEW_MATRIX * vec4(VERTEX, 1.0) / size;
	vec3 projected_x = vec3(texture(sprite_sheet, sprite_anim(projected_coords.zy, speed, frames)).r);
	vec3 projected_y = vec3(texture(sprite_sheet, sprite_anim(projected_coords.xz, speed, frames)).r);
	vec3 projected_z = vec3(texture(sprite_sheet, sprite_anim(projected_coords.xy, speed, frames)).r);
	vec3 world_normal = abs(INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	vec3 normal_weights = world_normal / (world_normal.x + world_normal.y + world_normal.z);
	
	ALBEDO = projected_x * normal_weights.x + projected_y * normal_weights.y + projected_z * normal_weights.z;
	ALBEDO = pow(ALBEDO * tint * brightness, vec3(contrast));
}
