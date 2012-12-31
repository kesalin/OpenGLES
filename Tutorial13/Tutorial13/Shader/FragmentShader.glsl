precision mediump float;

varying vec4 vDestinationColor;
varying vec2 vTextureCoordOut;

uniform sampler2D Sampler0;
uniform int disableTexture;
uniform int disableLight;

void main()
{
    vec4 texColor = texture2D(Sampler0, vTextureCoordOut);
    vec4 finalColor = texColor * vDestinationColor;
    
    if (disableTexture == 1 && disableLight == 1) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    }
    else if (disableTexture == 1) {
        gl_FragColor = vDestinationColor;
    }
    else if (disableLight == 1) {
        gl_FragColor = texColor;
    }
    else {
        gl_FragColor = finalColor;
    }

}