uniform mat4 projection;
uniform mat4 modelView;
uniform mat3 normalMatrix;

attribute vec4 vPosition;
attribute vec3 vNormal;
attribute vec3 vDiffuseMaterial;

varying vec3 vEyeSpaceNormal;
varying vec3 vDiffuse;

void main(void)
{
    gl_Position = projection * modelView * vPosition;
    
    vEyeSpaceNormal = normalMatrix * vNormal;
    vDiffuse = vDiffuseMaterial;
}