#version 300 es
precision mediump float;

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

uniform sampler2D tex;

void main() {
    vec4 pixColor = texture(tex, v_texcoord);
    
    // Standard luminosity weights for accurate human eye perception of gray
    float gray = dot(pixColor.rgb, vec3(0.299, 0.587, 0.114));
    
    // Output the calculated grayscale value while preserving the original alpha
    fragColor = vec4(vec3(gray), pixColor.a);
}
