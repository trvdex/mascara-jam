shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

uniform float outline_size = 1.0;        // tamaño base
uniform float size_variation = 1.0;      // cuánto cambia

uniform float min_alpha = 0.3;
uniform float max_alpha = 0.7;
uniform float speed = 2.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float alpha = tex.a;

    // Factor animado 0..1
    float t = (sin(TIME * speed) + 1.0) * 0.5;

    // Tamaño animado del outline
    float animated_size = outline_size + size_variation * t;
    vec2 px = TEXTURE_PIXEL_SIZE * animated_size;

    float outline = 0.0;
    outline += texture(TEXTURE, UV + vec2( px.x, 0.0)).a;
    outline += texture(TEXTURE, UV + vec2(-px.x, 0.0)).a;
    outline += texture(TEXTURE, UV + vec2(0.0,  px.y)).a;
    outline += texture(TEXTURE, UV + vec2(0.0, -px.y)).a;

    // Alpha animado SOLO para el outline
    float outline_alpha = mix(min_alpha, max_alpha, t);

    if (alpha == 0.0 && outline > 0.0) {
        COLOR = vec4(outline_color.rgb, outline_color.a * outline_alpha);
    } else {
        COLOR = tex;
    }
}
