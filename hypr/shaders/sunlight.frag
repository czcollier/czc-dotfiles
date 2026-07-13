#version 300 es
precision mediump float;

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

uniform sampler2D tex;

void main() {
    vec4 pixColor = texture(tex, v_texcoord);
    
    // 1. Core perceptual grayscale conversion
    float gray = dot(pixColor.rgb, vec3(0.299, 0.587, 0.114));
    
    // 2. High Contrast Multiplication
    // We subtract 0.5 to center the scaling transformation at neutral gray.
    // A factor of 2.2 aggressively stretches midtones outward toward absolute 0.0 or 1.0.
    float contrastFactor = 2.2;
    float highContrast = (gray - 0.5) * contrastFactor + 0.5;
    
    // 3. Force clamp into absolute binary boundaries to clip washed-out glare
    highContrast = clamp(highContrast, 0.0, 1.0);
    
    // Output sharp, hyper-etched monochrome pixels
    fragColor = vec4(vec3(highContrast), pixColor.a);
}
