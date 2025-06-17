shader_type canvas_item;
render_mode unshaded;

uniform float circle_size : hint_range(0.0, 1.05);

void fragment() {
	float ratio = 320.0 / 180.0;
	float dist = distance(vec2(0.5, 0.5), vec2(mix(0.5, UV.x, ratio), UV.y));
	COLOR.a = step(circle_size, dist);
}