shader_type canvas_item;

uniform sampler2D base_tex : hint_albedo;
uniform sampler2D blend_tex : hint_albedo;

uniform float percentage = 0.0;

uniform float wobble_amplitude_x = 5.0;
uniform float wobble_amplitude_y = 5.0;
uniform float wobble_period_x = 1.5;
uniform float wobble_period_y = 0.9;
uniform float wobble_period_xy = 4.5;
uniform float wobble_period_yx = 3.5;

void fragment() {
	// https://www.youtube.com/watch?v=zgjDanEDjTg
	float PI = 3.1415926;
	float displaceX = sin(wobble_period_x * TIME + wobble_period_xy * SCREEN_UV.y) * wobble_amplitude_x;
	float displaceY = sin(wobble_period_y * TIME + wobble_period_yx * SCREEN_UV.x) * wobble_amplitude_y;
	vec2 offset = vec2(displaceX, displaceY) * SCREEN_PIXEL_SIZE;

	COLOR = texture(base_tex, UV + offset) * (1.0 - percentage) + texture(blend_tex, UV + offset) * percentage;
}