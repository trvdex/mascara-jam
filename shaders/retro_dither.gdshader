shader_type canvas_item;

// === CONFIGURACIÓN RETRO EXTREMA ===
uniform float color_depth : hint_range(2.0, 32.0) = 5.0;  // MUY pocos colores
uniform float dither_strength : hint_range(0.0, 1.0) = 1.0;  // Dithering fuerte
uniform float pixel_size : hint_range(1.0, 16.0) = 8.0;  // Pixelación chunky
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.3;  // Líneas CRT
uniform float chromatic_aberration : hint_range(0.0, 5.0) = 1.5;  // Aberración de color
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.4;  // Oscurecimiento bordes
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

// Matriz de dithering Bayer 8x8 para más detalle
float get_dither_value(ivec2 coord) {
    int x = coord.x % 4;
    int y = coord.y % 4;
    float matrix[16] = float[](
        0.0, 8.0, 2.0, 10.0,
        12.0, 4.0, 14.0, 6.0,
        3.0, 11.0, 1.0, 9.0,
        15.0, 7.0, 13.0, 5.0
    );
    return matrix[y * 4 + x] / 16.0;
}

void fragment() {
    vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 pixelated_uv = floor(SCREEN_UV * screen_size / pixel_size) * pixel_size / screen_size;
    
    // Aberración cromática (separar canales RGB)
    float aberration = chromatic_aberration * SCREEN_PIXEL_SIZE.x;
    float r = texture(screen_texture, pixelated_uv + vec2(aberration, 0.0)).r;
    float g = texture(screen_texture, pixelated_uv).g;
    float b = texture(screen_texture, pixelated_uv - vec2(aberration, 0.0)).b;
    vec3 color = vec3(r, g, b);
    
    // Dithering
    ivec2 dither_coord = ivec2(FRAGCOORD.xy / pixel_size);
    float dither_value = get_dither_value(dither_coord);
    vec3 dithered = color + (dither_value - 0.5) * dither_strength / color_depth;
    
    // Posterizar (reducir colores drásticamente)
    vec3 posterized = floor(dithered * color_depth) / color_depth;
    
    // Scanlines CRT
    float scanline = sin(FRAGCOORD.y * 3.14159 / pixel_size) * 0.5 + 0.5;
    posterized *= 1.0 - (scanline_strength * (1.0 - scanline));
    
    // Viñeta (oscurecer bordes como CRT antiguo)
    vec2 uv_centered = SCREEN_UV - 0.5;
    float vignette = 1.0 - dot(uv_centered, uv_centered) * vignette_strength * 2.0;
    posterized *= vignette;
    
    // Añadir un poco de ruido para simular señal antigua
    float noise = fract(sin(dot(pixelated_uv + TIME * 0.01, vec2(12.9898, 78.233))) * 43758.5453);
    posterized += (noise - 0.5) * 0.02;
    
    COLOR = vec4(posterized, 1.0);
}
