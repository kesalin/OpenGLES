uniform mat4 projection;
uniform mat4 modelView;
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
varying vec3 vDestinationNormal;

void main(void)
{
    gl_Position = projection * modelView * vPosition;
    
    vec3 N = normalMatrix * vNormal;
    vec3 L = normalize(vLightPosition);
    vec3 E = vec3(0, 0, 1);
    vec3 H = normalize(L + E);

    float df = max(0.0, dot(N, L));
    float sf = max(0.0, dot(N, H));
    sf = pow(sf, shininess);

    vec3 color = vAmbientMaterial + df * vDiffuseMaterial + sf * vSpecularMaterial;
    vDestinationColor = vec4(color, 1);
    
    vTextureCoordOut = vTextureCoord;
    vDestinationNormal = vNormal;
}