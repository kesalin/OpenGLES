varying mediump vec3 vEyeSpaceNormal;
varying mediump vec3 vDiffuse;

uniform highp vec3 vLightPosition;
uniform highp vec3 vAmbientMaterial;
uniform highp vec3 vSpecularMaterial;
uniform highp float shininess;

void main()
{
    highp vec3 N = normalize(vEyeSpaceNormal);
    highp vec3 L = normalize(vLightPosition);
    highp vec3 E = vec3(0, 0, 1);
    highp vec3 H = normalize(L + E);

    highp float df = max(0.0, dot(N, L));
    highp float sf = max(0.0, dot(N, H));
    sf = pow(sf, shininess);

    highp float shadow = clamp(df * 4, 0.0, 1.0);
    
    mediump vec3 color = vAmbientMaterial + shadow * (df * vDiffuse + sf * vSpecularMaterial);
    
    gl_FragColor = vec4(color, 1);
}