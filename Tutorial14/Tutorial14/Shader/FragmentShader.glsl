precision mediump float;

varying vec3 vReflectDirection;
varying vec4 vDestinationColor;
varying vec2 vTextureCoordOut;

uniform samplerCube samplerForCube;
uniform sampler2D samplerFor2D;
uniform int textureMode;

void main()
{
    if (textureMode == 0) {
        gl_FragColor = textureCube(samplerForCube, vReflectDirection) * vDestinationColor;
    }
    else {
        gl_FragColor = texture2D(samplerFor2D, vTextureCoordOut) * vDestinationColor;
    }
}