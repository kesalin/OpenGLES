precision mediump float;

varying vec4 vDestinationColor;
varying vec2 vTextureCoordOut;

uniform float Alpha;
uniform int BlendMode;
uniform sampler2D Sampler0;
uniform sampler2D Sampler1;

// Blend the source and destination pixels.
//
vec3 blend (vec3 src, vec3 dst, int mode)
{
    if (mode == 1) {
        // LINEAR_DODGE
        // ADD
        return src + dst;
    }
    
    if (mode == 2) {
        // SUBTRACT
        return src - dst;
    }
    
    if (mode == 3) {
        // DARKEN
        return min(src, dst);
    }
    
    if (mode == 4) {
        // COLOUR_BURN
        return vec3((src.x == 0.0) ? 0.0 : (1.0 - ((1.0 - dst.x) / src.x)),
                (src.y == 0.0) ? 0.0 : (1.0 - ((1.0 - dst.y) / src.y)),
                (src.z == 0.0) ? 0.0 : (1.0 - ((1.0 - dst.z) / src.z)));
    }

    if (mode == 5) {
        // LINEAR_BURN
        return (src + dst) - 1.0;
    }
    
    if (mode == 6) {
        // LIGHTEN
        return max(src, dst);
    }
    
    if (mode == 7) {
        // SCREEN
        return (src + dst) - (src * dst);
    }
    
    if (mode == 8) {
        // COLOUR_DODGE
        return vec3((src.x == 1.0) ? 1.0 : min(1.0, dst.x / (1.0 - src.x)),
                (src.y == 1.0) ? 1.0 : min(1.0, dst.y / (1.0 - src.y)),
                (src.z == 1.0) ? 1.0 : min(1.0, dst.z / (1.0 - src.z)));
    }
    
    if (mode == 9) {
        // OVERLAY
        return vec3((dst.x <= 0.5) ? (2.0 * src.x * dst.x) : (1.0 - 2.0 * (1.0 - dst.x) * (1.0 - src.x)),
                (dst.y <= 0.5) ? (2.0 * src.y * dst.y) : (1.0 - 2.0 * (1.0 - dst.y) * (1.0 - src.y)),
                (dst.z <= 0.5) ? (2.0 * src.z * dst.z) : (1.0 - 2.0 * (1.0 - dst.z) * (1.0 - src.z)));
    }
    
    if (mode == 10) {
        // SOFT_LIGHT
        return vec3((src.x <= 0.5) ? (dst.x - (1.0 - 2.0 * src.x) * dst.x * (1.0 - dst.x)) : (((src.x > 0.5) && (dst.x <= 0.25)) ? (dst.x + (2.0 * src.x - 1.0) * (4.0 * dst.x * (4.0 * dst.x + 1.0) * (dst.x - 1.0) + 7.0 * dst.x)) : (dst.x + (2.0 * src.x - 1.0) * (sqrt(dst.x) - dst.x))),
                (src.y <= 0.5) ? (dst.y - (1.0 - 2.0 * src.y) * dst.y * (1.0 - dst.y)) : (((src.y > 0.5) && (dst.y <= 0.25)) ? (dst.y + (2.0 * src.y - 1.0) * (4.0 * dst.y * (4.0 * dst.y + 1.0) * (dst.y - 1.0) + 7.0 * dst.y)) : (dst.y + (2.0 * src.y - 1.0) * (sqrt(dst.y) - dst.y))),
                (src.z <= 0.5) ? (dst.z - (1.0 - 2.0 * src.z) * dst.z * (1.0 - dst.z)) : (((src.z > 0.5) && (dst.z <= 0.25)) ? (dst.z + (2.0 * src.z - 1.0) * (4.0 * dst.z * (4.0 * dst.z + 1.0) * (dst.z - 1.0) + 7.0 * dst.z)) : (dst.z + (2.0 * src.z - 1.0) * (sqrt(dst.z) - dst.z))));
    }
    
    if (mode == 11) {
        // HARD_LIGHT
        return vec3((src.x <= 0.5) ? (2.0 * src.x * dst.x) : (1.0 - 2.0 * (1.0 - src.x) * (1.0 - dst.x)),
            (src.y <= 0.5) ? (2.0 * src.y * dst.y) : (1.0 - 2.0 * (1.0 - src.y) * (1.0 - dst.y)),
            (src.z <= 0.5) ? (2.0 * src.z * dst.z) : (1.0 - 2.0 * (1.0 - src.z) * (1.0 - dst.z)));
    }
    
    if (mode == 12) {
        // VIVID_LIGHT
        return vec3((src.x <= 0.5) ? (1.0 - (1.0 - dst.x) / (2.0 * src.x)) : (dst.x / (2.0 * (1.0 - src.x))),
                (src.y <= 0.5) ? (1.0 - (1.0 - dst.y) / (2.0 * src.y)) : (dst.y / (2.0 * (1.0 - src.y))),
                (src.z <= 0.5) ? (1.0 - (1.0 - dst.z) / (2.0 * src.z)) : (dst.z / (2.0 * (1.0 - src.z))));
    }
    
    if (mode == 13) {
        // LINEAR_LIGHT
        return 2.0 * src + dst - 1.0;
    }
    
    if (mode == 14) {
        // PIN_LIGHT
        return vec3((src.x > 0.5) ? max(dst.x, 2.0 * (src.x - 0.5)) : min(dst.x, 2.0 * src.x),
                (src.x > 0.5) ? max(dst.y, 2.0 * (src.y - 0.5)) : min(dst.y, 2.0 * src.y),
                (src.z > 0.5) ? max(dst.z, 2.0 * (src.z - 0.5)) : min(dst.z, 2.0 * src.z));
    }
    
    if (mode == 15) {
        // DIFFERENCE
        return abs(dst - src);
    }
    
    if (mode == 16) {
        // EXCLUSION
        return src + dst - 2.0 * src * dst;
    }
    
    if (mode == 17) {
        // INTERPOLATE
        return src * Alpha + dst * (1.0 - Alpha);
    }
    
    if (mode == 18) {
        return src + dst - 0.5;
    }
    
    // MULTIPLY
    return src * dst;
}

void main()
{
    vec4 dst = texture2D(Sampler0, vTextureCoordOut);
    vec4 src = texture2D(Sampler1, vTextureCoordOut);
    
    // Apply blend operation
    vec3 color = clamp(blend(src.xyz, dst.xyz, BlendMode), 0.0, 1.0);
    
    vec4 texColor = vec4(color, 1.0);
    //vec4 finalColor = texColor;                         // Disable light
    vec4 finalColor = texColor * vDestinationColor;     // enable light
    
    gl_FragColor = finalColor;
}