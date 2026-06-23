#include <flutter/runtime_effect.glsl>

uniform vec2 u_resolution;
uniform float u_time;
uniform float u_brightness;

#define iResolution u_resolution
#define iTime u_time

out vec4 fragColor;

#define H(i,j) fract(sin(dot(ceil(P+vec2(i,j)), iResolution.xy )) * 4e3)

float N(vec2 P) {
    float s = 0.0;
    float i = 0.0;
    float w = 0.5;
    for (; i < 3.0 ; i++, w *= 0.4, P *= 1.9 ) {
        vec2 F = fract( P *= mat2(0.866, -0.5, 0.5, 0.866) );
        F *= F * (3.0 - F - F);
        s += w * mix( mix(H(0.0, 0.0), H(1.0, 0.0), F.x),
                      mix(H(0.0, 1.0), H(1.0, 1.0), F.x),
                      F.y );
    }
    return s;
}

vec3 portal(vec2 pixel, float time) {
    float l = length(pixel);
    float a = atan(pixel.y, pixel.x) / 6.28318 + 0.5;
    float k = 10.0;

    a = fract(a + l * 0.3 - time * 0.01);
    vec2 U = vec2(l + time * 0.3, a);

    return vec3[]( vec3(0.18, 0.53, 0.09),
                   vec3(0.56, 0.89, 0.16),
                   vec3(0.35, 0.84, 0.11),
                   vec3(0.92, 0.98, 0.85)
                 ) [ int( 4.0 * pow( mix( N(U * k), N(U * k - vec2(0.0, k)), U.y) * 1.5, 2.5))];
}

float portalRadius(float angle, float time) {
    float base = 2.5;
    float amp = 0.22;
    vec2 p = vec2(angle * 0.5 + time * 0.1, cos(angle * 0.7 + time * 0.12));
    return base + amp * (N(p) * 2.0 - 1.0);
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;

    int sample_count = 3;
    vec3 sum = vec3(0.0);

    for (int m = 0; m < sample_count; m++) {
        for (int n = 0; n < sample_count; n++) {
            vec2 o = (vec2(float(m), float(n)) + 0.5) / float(sample_count);
            vec2 st = (2.0 * (fragCoord + o) - iResolution.xy) / iResolution.y;
            st *= 3.0;
            sum += portal(st, iTime);
        }
    }

    vec3 color = sum / float(sample_count * sample_count);
    fragColor = vec4(color * u_brightness, 1.0);
}
