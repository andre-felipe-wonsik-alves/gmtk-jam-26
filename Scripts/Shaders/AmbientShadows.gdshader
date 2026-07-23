shader_type canvas_item;


uniform float point_A: hint_range(0.0, 1.0, 0.1) = 0.3;
uniform float point_B: hint_range(0.0, 1.0, 0.1) = 0.7;
uniform vec2 scroll = vec2(0.1, 0.5);
uniform vec2 scroll2 = vec2(0.1, 0.5);
uniform float size = 0.3;
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform sampler2D noise: repeat_enable;
uniform sampler2D noise2: repeat_enable;
uniform sampler2D gradient;

float contrast_stretch(vec3 M, vec2 A, vec2 B, float r) {
	float m, s1, r1;
	if (r < A.x) {
		m = M.x;
		s1 = 0.0;
		r1 = 0.0;
	} else if (r >= A.x && r < B.x) {
		m = M.y;
		s1 = A.y;
		r1 = A.x;
	} else {
		m = M.z;
		s1 = B.y;
		r1 = B.x;
	}
	return s1 + m * (r - r1);
}

void fragment() {
	vec2 breakpoint_A = vec2(point_A, point_A*0.8);
	vec2 breakpoint_B = vec2(point_B, point_B*0.8);
	
	vec3 slopes = vec3(1.0, 1.0, 1.0);
	float m = (breakpoint_A.y - 0.0) / (breakpoint_A.x - 0.0);
	float m1 = (breakpoint_B.y - breakpoint_A.y) / (breakpoint_B.x - breakpoint_A.x);
	float m2 = (1.0 - breakpoint_B.y) / (1.0 - breakpoint_B.x);
	
	slopes = vec3(m, m1, m2);
	
	float pixelColor = texture(TEXTURE, UV).r;
	float noiseColor = texture(noise, UV+scroll2*TIME).r;
	float noise2Color = texture(noise2, UV+scroll*TIME).r;
	float energy = pixelColor * (noise2Color + noiseColor);
	energy = contrast_stretch(slopes, breakpoint_A, breakpoint_B, energy);
	COLOR = texture(gradient, vec2(energy));
}