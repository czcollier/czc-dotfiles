#version 300 es
precision mediump float;
in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;
uniform sampler2D tex;
void main() {
    vec4 pixColor = texture(tex, v_texcoord);
    float gray = dot(pixColor.rgb, vec3(0.299, 0.587, 0.114));
    vec3 mixedColor = mix(vec3(gray), pixColor.rgb, 0.80);
    fragColor = vec4(mixedColor, pixColor.a);
}