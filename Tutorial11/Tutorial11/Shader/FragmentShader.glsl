#define OVERLAY

precision mediump float;

varying vec4 vDestinationColor;
varying vec2 vTextureCoordOut;

uniform sampler2D Sampler0;
uniform sampler2D Sampler1;

// Blend the source and destination pixels.
//
vec3 blend (vec3 src, vec3 dst)
{
#ifdef ADD
    return src + dst;
#endif

#ifdef SUBTRACT
    return src - dst;
#endif

#ifdef MULTIPLY
    return src * dst;
#endif

#ifdef DARKEN
    return min(src, dst);
#endif

#ifdef COLOUR_BURN
    return vec3((src.x == 0.0) ? 0.0 : (1.0 - ((1.0 - dst.x) / src.x)),
            (src.y == 0.0) ? 0.0 : (1.0 - ((1.0 - dst.y) / src.y)),
            (src.z == 0.0) ? 0.0 : (1.0 - ((1.0 - dst.z) / src.z)));
#endif

#ifdef LINEAR_BURN
    return (src + dst) - 1.0;
#endif

#ifdef LIGHTEN
    return max(src, dst);
#endif

#ifdef SCREEN
    return (src + dst) - (src * dst);
#endif

#ifdef COLOUR_DODGE
    return vec3((src.x == 1.0) ? 1.0 : min(1.0, dst.x / (1.0 - src.x)),
            (src.y == 1.0) ? 1.0 : min(1.0, dst.y / (1.0 - src.y)),
            (src.z == 1.0) ? 1.0 : min(1.0, dst.z / (1.0 - src.z)));
#endif
            
#ifdef LINEAR_DODGE
    return src + dst;
#endif

#ifdef OVERLAY
    return vec3((dst.x <= 0.5) ? (2.0 * src.x * dst.x) : (1.0 - 2.0 * (1.0 - dst.x) * (1.0 - src.x)),
            (dst.y <= 0.5) ? (2.0 * src.y * dst.y) : (1.0 - 2.0 * (1.0 - dst.y) * (1.0 - src.y)),
            (dst.z <= 0.5) ? (2.0 * src.z * dst.z) : (1.0 - 2.0 * (1.0 - dst.z) * (1.0 - src.z)));
#endif

#ifdef SOFT_LIGHT
    return vec3((src.x <= 0.5) ? (dst.x - (1.0 - 2.0 * src.x) * dst.x * (1.0 - dst.x)) : (((src.x > 0.5) && (dst.x <= 0.25)) ? (dst.x + (2.0 * src.x - 1.0) * (4.0 * dst.x * (4.0 * dst.x + 1.0) * (dst.x - 1.0) + 7.0 * dst.x)) : (dst.x + (2.0 * src.x - 1.0) * (sqrt(dst.x) - dst.x))),
            (src.y <= 0.5) ? (dst.y - (1.0 - 2.0 * src.y) * dst.y * (1.0 - dst.y)) : (((src.y > 0.5) && (dst.y <= 0.25)) ? (dst.y + (2.0 * src.y - 1.0) * (4.0 * dst.y * (4.0 * dst.y + 1.0) * (dst.y - 1.0) + 7.0 * dst.y)) : (dst.y + (2.0 * src.y - 1.0) * (sqrt(dst.y) - dst.y))),
            (src.z <= 0.5) ? (dst.z - (1.0 - 2.0 * src.z) * dst.z * (1.0 - dst.z)) : (((src.z > 0.5) && (dst.z <= 0.25)) ? (dst.z + (2.0 * src.z - 1.0) * (4.0 * dst.z * (4.0 * dst.z + 1.0) * (dst.z - 1.0) + 7.0 * dst.z)) : (dst.z + (2.0 * src.z - 1.0) * (sqrt(dst.z) - dst.z))));
#endif

#ifdef HARD_LIGHT
    return vec3((src.x <= 0.5) ? (2.0 * src.x * dst.x) : (1.0 - 2.0 * (1.0 - src.x) * (1.0 - dst.x)),
            (src.y <= 0.5) ? (2.0 * src.y * dst.y) : (1.0 - 2.0 * (1.0 - src.y) * (1.0 - dst.y)),
            (src.z <= 0.5) ? (2.0 * src.z * dst.z) : (1.0 - 2.0 * (1.0 - src.z) * (1.0 - dst.z)));
#endif

#ifdef VIVID_LIGHT
    return vec3((src.x <= 0.5) ? (1.0 - (1.0 - dst.x) / (2.0 * src.x)) : (dst.x / (2.0 * (1.0 - src.x))),
            (src.y <= 0.5) ? (1.0 - (1.0 - dst.y) / (2.0 * src.y)) : (dst.y / (2.0 * (1.0 - src.y))),
            (src.z <= 0.5) ? (1.0 - (1.0 - dst.z) / (2.0 * src.z)) : (dst.z / (2.0 * (1.0 - src.z))));
#endif

#ifdef LINEAR_LIGHT
    return 2.0 * src + dst - 1.0;
#endif

#ifdef PIN_LIGHT
    return vec3((src.x > 0.5) ? max(dst.x, 2.0 * (src.x - 0.5)) : min(dst.x, 2.0 * src.x),
            (src.x > 0.5) ? max(dst.y, 2.0 * (src.y - 0.5)) : min(dst.y, 2.0 * src.y),
            (src.z > 0.5) ? max(dst.z, 2.0 * (src.z - 0.5)) : min(dst.z, 2.0 * src.z));
#endif

#ifdef DIFFERENCE
    return abs(dst - src);
#endif

#ifdef EXCLUSION
    return src + dst - 2.0 * src * dst;
#endif
}

void main()
{
    vec4 dst = texture2D(Sampler0, vTextureCoordOut);
    vec4 src = texture2D(Sampler1, vTextureCoordOut);// * vDestinationColor;
    
    // Apply blend operation
    vec3 colour = clamp(blend(src.xyz, dst.xyz), 0.0, 1.0);

    gl_FragColor.xyz = colour;
    gl_FragColor.w = 1.0;
}