//
//  OpenGLView.m
//  Tutorial05
//
//  Created by kesalin on 12-11-24.
//  Copyright (c) Copyright (c) 2012 年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import "OpenGLView.h"
#import "GLESUtils.h"


// Declare private members inside anonymous category
@interface OpenGLView()
{
    ksMatrix4 _shouldModelViewMatrix;
    ksMatrix4 _elbowModelViewMatrix;
    
    float _rotateColorCube;
    
    CADisplayLink * _displayLink;
}

- (void)setupLayer;
- (void)setupContext;
- (void)setupBuffers;
- (void)destoryBuffers;

- (void)setupProgram;
- (void)setupProjection;

- (void)updateShoulderTransform;
- (void)updateElbowTransform;
- (void)resetTransform;

- (void)updateRectangleTransform;
- (void)updateColorCubeTransform;
- (void)drawColorCube;

- (void)drawCube:(ksColor) color;

@end

@implementation OpenGLView

@synthesize rotateShoulder = _rotateShoulder;
@synthesize rotateElbow = _rotateElbow;

+ (Class)layerClass {
    // Support for OpenGL ES
    return [CAEAGLLayer class];
}

- (void)setupLayer
{
    _eaglLayer = (CAEAGLLayer*) self.layer;
    
    // Make CALayer visibale
    _eaglLayer.opaque = YES;
    
    // Set drawable properties
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext {
    // Set OpenGL version, here is OpenGL ES 2.0 
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@" >> Error: Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    // Set OpenGL context
    if (![EAGLContext setCurrentContext:_context]) {
        _context = nil;
        NSLog(@" >> Error: Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupBuffers {
    glGenRenderbuffers(1, &_colorRenderBuffer);
    // Set as current renderbuffer
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    // Allocate color renderbuffer
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    glGenFramebuffers(1, &_frameBuffer);
    // Set as current framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    // Attach _colorRenderBuffer to _frameBuffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, 
                              GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)destoryBuffers
{
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
    
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
}

- (void)cleanup
{
    [self destoryBuffers];
    
    if (_programHandle != 0) {
        glDeleteProgram(_programHandle);
        _programHandle = 0;
    }

    if (_context && [EAGLContext currentContext] == _context)
        [EAGLContext setCurrentContext:nil];
    
    _context = nil;
}

- (void)setupProgram
{
    // Load shaders
    //
    NSString * vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"VertexShader"
                                                                  ofType:@"glsl"];
    NSString * fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"FragmentShader"
                                                                    ofType:@"glsl"];
    
    _programHandle = [GLESUtils loadProgram:vertexShaderPath
                 withFragmentShaderFilepath:fragmentShaderPath];
    if (_programHandle == 0) {
        NSLog(@" >> Error: Failed to setup program.");
        return;
    }
    
    glUseProgram(_programHandle);
    
    // Get the attribute position slot from program
    //
    _positionSlot = glGetAttribLocation(_programHandle, "vPosition");
    
    // Get the attribute color slot from program
    //
    _colorSlot = glGetAttribLocation(_programHandle, "vSourceColor");
    
    // Get the uniform model-view matrix slot from program
    //
    _modelViewSlot = glGetUniformLocation(_programHandle, "modelView");
    
    // Get the uniform projection matrix slot from program
    //
    _projectionSlot = glGetUniformLocation(_programHandle, "projection");
}

-(void)setupProjection
{
    // Generate a perspective matrix with a 60 degree FOV
    //
    float aspect = self.frame.size.width / self.frame.size.height;
    ksMatrixLoadIdentity(&_projectionMatrix);
    ksPerspective(&_projectionMatrix, 60.0, aspect, 1.0f, 20.0f);
    
    // Load projection matrix
    glUniformMatrix4fv(_projectionSlot, 1, GL_FALSE, (GLfloat*)&_projectionMatrix.m[0][0]);
    
    glEnable(GL_CULL_FACE);
}

- (void) updateShoulderTransform
{
    ksMatrixLoadIdentity(&_shouldModelViewMatrix);
    
    ksMatrixTranslate(&_shouldModelViewMatrix, -0.0, 0.0, -5.5);
    
    // Rotate the shoulder
    //
    ksMatrixRotate(&_shouldModelViewMatrix, self.rotateShoulder, 0.0, 0.0, 1.0);
    
    // Scale the cube to be a shoulder
    //
    ksMatrixCopy(&_modelViewMatrix, &_shouldModelViewMatrix);
    ksMatrixScale(&_modelViewMatrix, 1.5, 0.6, 0.6);
    
    // Load the model-view matrix
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
}

- (void) updateElbowTransform
{
    // Relative to shoulder
    //
    ksMatrixCopy(&_elbowModelViewMatrix, &_shouldModelViewMatrix);
    
    // Translate away from shoulder
    //
    ksMatrixTranslate(&_elbowModelViewMatrix, 1.5, 0.0, 0.0);
    
    // Rotate the elbow
    //
    ksMatrixRotate(&_elbowModelViewMatrix, self.rotateElbow, 0.0, 0.0, 1.0);
    
    // Scale the cube to be a elbow
    ksMatrixCopy(&_modelViewMatrix, &_elbowModelViewMatrix);
    ksMatrixScale(&_modelViewMatrix, 1.0, 0.4, 0.4);
    
    // Load the model-view matrix
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
}

- (void)drawCube:(ksColor) color
{
    GLfloat vertices[] = {
        0.0f, -0.5f, 0.5f,
        0.0f, 0.5f, 0.5f,
        1.0f, 0.5f, 0.5f,
        1.0f, -0.5f, 0.5f,
        
        1.0f, -0.5f, -0.5f,
        1.0f, 0.5f, -0.5f,
        0.0f, 0.5f, -0.5f,
        0.0f, -0.5f, -0.5f,
    };
    
    GLubyte indices[] = {
        0, 1, 1, 2, 2, 3, 3, 0,
        4, 5, 5, 6, 6, 7, 7, 4,
        0, 7, 1, 6, 2, 5, 3, 4
    };
    
    glVertexAttrib4f(_colorSlot, color.r, color.g, color.b, color.a);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices );
    glEnableVertexAttribArray(_positionSlot);
    
    glDrawElements(GL_LINES, sizeof(indices)/sizeof(GLubyte), GL_UNSIGNED_BYTE, indices);
}

- (void) updateRectangleTransform
{ 
    ksMatrixLoadIdentity(&_modelViewMatrix);
    
    ksMatrixTranslate(&_modelViewMatrix, 0.0, -2, -5.5);
    
    // Load the model-view matrix
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
}

- (void)drawColorRectangle
{
    GLfloat vertices[] = {
        -0.5f, -0.5f, 0.0f, 1.0, 0.0, 0.0, 1.0,
        -0.5f, 0.5f, 0.0f, 0.0, 0.0, 1.0, 1.0,
        0.5f, 0.5f, 0.0f, 1.0, 1.0, 0.0, 1.0,
        0.5f, -0.5f, 0.0f, 1.0, 1.0, 1.0, 1.0
    };
    
    GLubyte indices[] = {
        0, 3, 2, 
        0, 2, 1
    };

    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 7 * sizeof(float), vertices);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, 7 * sizeof(float), vertices + 3);
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(GLubyte), GL_UNSIGNED_BYTE, indices);
    glDisableVertexAttribArray(_colorSlot);
}

- (void) updateColorCubeTransform
{
    ksMatrixLoadIdentity(&_modelViewMatrix);
    
    ksMatrixTranslate(&_modelViewMatrix, 0.0, -2, -5.5);
    
    ksMatrixRotate(&_modelViewMatrix, _rotateColorCube, 0.0, 1.0, 0.0);
    
    // Load the model-view matrix
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
}

- (void) drawColorCube
{
    GLfloat vertices[] = {
        -0.5f, -0.5f, 0.5f, 1.0, 0.0, 0.0, 1.0,     // red
        -0.5f, 0.5f, 0.5f, 1.0, 1.0, 0.0, 1.0,      // yellow
        0.5f, 0.5f, 0.5f, 0.0, 0.0, 1.0, 1.0,       // blue
        0.5f, -0.5f, 0.5f, 1.0, 1.0, 1.0, 1.0,      // white
        
        0.5f, -0.5f, -0.5f, 1.0, 1.0, 0.0, 1.0,     // yellow
        0.5f, 0.5f, -0.5f, 1.0, 0.0, 0.0, 1.0,      // red
        -0.5f, 0.5f, -0.5f, 1.0, 1.0, 1.0, 1.0,     // white
        -0.5f, -0.5f, -0.5f, 0.0, 0.0, 1.0, 1.0,    // blue
    };
    
    GLubyte indices[] = {
        // Front face
        0, 3, 2, 0, 2, 1,
        
        // Back face
        7, 5, 4, 7, 6, 5,
        
        // Left face
        0, 1, 6, 0, 6, 7,
        
        // Right face
        3, 4, 5, 3, 5, 2,
        
        // Up face
        1, 2, 5, 1, 5, 6,
        
        // Down face
        0, 7, 4, 0, 4, 3
    };
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 7 * sizeof(float), vertices);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, 7 * sizeof(float), vertices + 3);
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(GLubyte), GL_UNSIGNED_BYTE, indices);
    glDisableVertexAttribArray(_colorSlot);
}

- (void)render
{
    if (_context == nil)
        return;
    
    ksColor colorRed = {1, 0, 0, 1};
    ksColor colorWhite = {1, 1, 1, 1};

    glClearColor(0.0, 1.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Setup viewport
    //
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);    
    
    // Draw color rectangle
    //
//    [self updateRectangleTransform];
//    [self drawColorRectangle];
    
    // Draw color cube
    //
    [self updateColorCubeTransform];
    [self drawColorCube];
    

    // Draw shoulder
    //
    [self updateShoulderTransform];
    [self drawCube:colorRed];
    
    // Draw elbow
    //
    [self updateElbowTransform];
    [self drawCube:colorWhite];

    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupLayer];        
        [self setupContext];
        [self setupProgram];
        [self setupProjection];

        [self resetTransform];
    }

    return self;
}

- (void)layoutSubviews
{
    [EAGLContext setCurrentContext:_context];
    glUseProgram(_programHandle);

    [self destoryBuffers];
    
    [self setupBuffers];

    [self render];
}

#pragma mark - Transform properties

- (void)resetTransform
{
    self.rotateShoulder = 0.0;
    self.rotateElbow = 0.0;
    
    [self updateShoulderTransform];
    [self updateElbowTransform];
}

- (void)setRotateShoulder:(float)rotateShoulder
{
    _rotateShoulder = rotateShoulder;
    
    [self render];
}

- (float)rotateShoulder
{
    return _rotateShoulder;
}

- (void)setRotateElbow:(float)rotateElbow
{
    _rotateElbow = rotateElbow;
    
    [self render];
}

- (float)rotateElbow
{
    return _rotateElbow;
}

- (void)toggleDisplayLink
{
    if (_displayLink == nil) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    else {
        [_displayLink invalidate];
        [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _displayLink = nil;
    }
}

- (void)displayLinkCallback:(CADisplayLink*)displayLink
{
    _rotateColorCube += displayLink.duration * 90;
    
    [self render];
}

#pragma mark

@end
