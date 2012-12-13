uniform mat4 projection;
uniform mat4 modelView;
attribute vec4 vPosition; 

attribute vec4 vSourceColor;
varying vec4 vDestinationColor;

void main(void)
{
    gl_Position = projection * modelView * vPosition;
    vDestinationColor = vSourceColor;
}