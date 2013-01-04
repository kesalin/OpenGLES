precision mediump float;

varying vec4 vDestinationColor;
varying vec3 vDestinationNormal;
varying vec2 vTextureCoordOut;

uniform samplerCube samplerForCube;
uniform sampler2D samplerFor2D;
uniform int textureMode;

void main()
{
    if (textureMode == 0) {
        gl_FragColor = textureCube(samplerForCube, vDestinationNormal);// * vDestinationColor;
    }
    else {
        gl_FragColor = texture2D(samplerFor2D, vTextureCoordOut);// * vDestinationColor;
    }
}