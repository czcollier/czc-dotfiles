// ~/.config/hypr/shaders/sharpen_text.frag
#version 300 es
precision mediump float;
in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;
uniform sampler2D tex;

void main() {
    // Determine the distance between pixels on a standard 1200p panel
    vec2 stepSize = vec2(1.0 / 1920.0, 1.0 / 1200.0);
    
    // Core pixel samples (Center and 4 cardinal directions)
    vec3 center = texture(tex, v_texcoord).rgb;
    vec3 top    = texture(tex, v_texcoord + vec2(0.0, stepSize.y)).rgb;
    vec3 bottom = texture(tex, v_texcoord - vec2(0.0, stepSize.y)).rgb;
    vec3 left   = texture(tex, v_texcoord - vec2(stepSize.x, 0.0)).rgb;
    vec3 right  = texture(tex, v_texcoord + vec2(stepSize.x, 0.0)).rgb;
    
    // Laplacian edge weight calculation
    // Sharpness factor (0.25 is perfect for clear terminal text without creating artifacts)
    float amount = 0.25;
    vec3 sharpened = center + (center * 4.0 - top - bottom - left - right) * amount;
    
    fragColor = vec4(clamp(sharpened, 0.0, 1.0), texture(tex, v_texcoord).a);
}
