#version 300 es
precision mediump float;

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

uniform sampler2D tex;

void main() {
    vec4 pixColor = texture(tex, v_texcoord);
    
    // 1. Convert to clean, standard perceptual grayscale
    float gray = dot(pixColor.rgb, vec3(0.299, 0.587, 0.114));
    
    // 2. Dimming Modifier (0.75 means 75% max brightness to take the edge off white backgrounds)
    float dimmedGray = gray * 0.65;
    
    // 3. Map the gray value to a custom warm amber/sepia tint vector
    // Red gets 100% of the gray value, Green gets 86% (creating amber), Blue drops down to 55%
    vec3 sepiaTint = vec3(0.92, 0.86, 0.65);
    vec3 finalColor = vec3(dimmedGray) * sepiaTint;
    
    // Output the processed pixel back to the monitor frame buffer
    fragColor = vec4(finalColor, pixColor.a);
}
