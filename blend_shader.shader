shader_type canvas_item;

uniform sampler2D blend_tex : hint_albedo;

uniform float percentage = 0.0;
uniform float wobbleSpeed = 1.5;
uniform float wobbleScale = 20.0;

void fragment() {
	// https://www.youtube.com/watch?v=zgjDanEDjTg
	float PI = 3.1415926;
	float time2 = TIME * wobbleSpeed;
	float displaceX = sin(time2);
	float displaceY = sin(time2 * 0.9);
	vec2 offset = vec2(displaceX, displaceY) * SCREEN_PIXEL_SIZE * wobbleScale;

	COLOR = texture(TEXTURE, UV + offset) * (1.0 - percentage) +
		texture(blend_tex, UV + offset) * percentage;
}