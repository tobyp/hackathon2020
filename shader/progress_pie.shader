shader_type canvas_item;

uniform float percentage = 1.0;

const float PI = 3.14159265358979323846;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float angle = mod((atan(UV.y - 0.5, UV.x - 0.5) + PI / 4.0), PI);
	float maxAngle = percentage * PI;
	if (angle > maxAngle)
		color.a *= 0.5 + percentage * 0.5;

	COLOR = color;
}