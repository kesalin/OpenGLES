uniform mat4 projection;
uniform mat4 modelView;
attribute vec4 vPosition;
attribute vec2 vTextureCoord;

uniform mat3 normalMatrix;
uniform vec3 vLightPosition;
uniform vec4 vAmbientMaterial;
uniform vec4 vSpecularMaterial;
uniform float shininess;

attribute vec3 vNormal;
attribute vec4 vDiffuseMaterial;

varying vec4 vDestinationColor;
varying vec2 vTextureCoordOut;

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

    vec4 color = vAmbientMaterial + df * vDiffuseMaterial + sf * vSpecularMaterial;
    vDestinationColor = color;
    //vDestinationColor = df * vDiffuseMaterial;
    vTextureCoordOut = vTextureCoord;
}