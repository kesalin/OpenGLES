uniform mat4 projection;
uniform mat4 modelView;
uniform mat3 model;
uniform vec3 vEyePosition;

attribute vec4 vPosition;
attribute vec2 vTextureCoord;

uniform mat3 normalMatrix;
uniform vec3 vLightPosition;
uniform vec3 vAmbientMaterial;
uniform vec3 vSpecularMaterial;
uniform float shininess;

attribute vec3 vNormal;
attribute vec3 vDiffuseMaterial;

varying vec4 vDestinationColor;
varying vec2 vTextureCoordOut;
varying vec3 vReflectDirection;

void main(void)
{
    gl_Position = projection * modelView * vPosition;
    
    // light
    //
    vec3 N = normalMatrix * vNormal;
    vec3 L = normalize(vLightPosition);
    vec3 H = normalize(L + vEyePosition);

    float df = max(0.0, dot(N, L));
    float sf = max(0.0, dot(N, H));
    sf = pow(sf, shininess);

    vec3 color = vAmbientMaterial + df * vDiffuseMaterial + sf * vSpecularMaterial;
    vDestinationColor = vec4(color, 1);
    
    vTextureCoordOut = vTextureCoord;
    
    // compute relect direction
    //
    vec3 eyeDirection = normalize(vPosition.xyz - vEyePosition);
    vReflectDirection = reflect(eyeDirection, vNormal); // Reflection in object space
    vReflectDirection = model * vReflectDirection;      // Transform to world sapce
}