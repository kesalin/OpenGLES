uniform mat4 mvpMatrix;
attribute vec4 vPosition; 
 
void main(void)
{
    gl_Position = mvpMatrix * vPosition;
}