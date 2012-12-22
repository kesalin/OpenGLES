precision mediump float;

varying vec4 vDestinationColor;
varying vec2 vTextureCoordOut;

uniform sampler2D Sampler;

void main()
{
    gl_FragColor = texture2D(Sampler, vTextureCoordOut) * vDestinationColor;
}