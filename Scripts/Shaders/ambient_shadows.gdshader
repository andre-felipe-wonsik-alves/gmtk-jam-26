shader_type canvas_item;

uniform vec2 scroll = vec2(0.1, 0.5);
uniform vec2 scroll2 = vec2(0.1, 0.5);
uniform float size = 0.3;
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform sampler2D noise: repeat_enable;
uniform sampler2D noise2: repeat_enable;
uniform sampler2D gradient;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float pixelColor = texture(TEXTURE, UV).r;
	float noiseColor = texture(noise, UV+scroll2*TIME).r;
	float noise2Color = texture(noise2, UV+scroll*TIME).r;
	float energy = pixelColor + (noise2Color * noiseColor - (size - UV.y));
	COLOR = texture(gradient, vec2(energy));
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
