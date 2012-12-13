//
//  OpenGLView.m
//  Tutorial05
//
//  Created by kesalin@gmail.com on 12-11-24.
//  Copyright (c) 2012 年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import "OpenGLView.h"
#import "GLESUtils.h"
#import "ParametricEquations.h"

// Declare private members inside anonymous category
@interface OpenGLView()
{
    float _rotateColorCube;
    
    CADisplayLink * _displayLink;
    
    GLuint _vertexBuffer;
    GLuint _lineIndexBuffer;
    int _lineIndexCount;
    
    int _triangleIndexCount;
    GLuint _triangleIndexBuffer;
}

- (void)setupLayer;
- (void)setupContext;
- (void)setupBuffers;
- (void)destoryBuffers;

- (void)setupProgram;
- (void)setupProjection;

- (void)setupVBOs;
- (void)destoryVBOs;

- (ISurface *)createSurface;

@end

@implementation OpenGLView

#pragma mark- Initilize GL

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

- (void)setupContext
{
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

- (void)setupBuffers
{
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
    if (_colorRenderBuffer != 0) {
        glDeleteRenderbuffers(1, &_colorRenderBuffer);
        _colorRenderBuffer = 0;
    }
    
    if (_frameBuffer != 0) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
}

- (void)cleanup
{
    [self destoryVBOs];

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

#pragma mark

-(void)setupProjection
{
    // Generate a perspective matrix with a 60 degree FOV
    //
    float aspect = self.frame.size.width / self.frame.size.height;
    ksMatrixLoadIdentity(&_projectionMatrix);
    ksPerspective(&_projectionMatrix, 60.0, aspect, 5.0f, 10.0f);
    
    // Load projection matrix
    glUniformMatrix4fv(_projectionSlot, 1, GL_FALSE, (GLfloat*)&_projectionMatrix.m[0][0]);
    
    glEnable(GL_CULL_FACE);
}

- (void) updateColorCubeTransform
{
    ksMatrixLoadIdentity(&_modelViewMatrix);
    
    ksTranslate(&_modelViewMatrix, 0.0, 0.0, -7);
    
    ksRotate(&_modelViewMatrix, _rotateColorCube, 0.0, 1.0, 0.0);
    
    // Load the model-view matrix
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
}

- (ISurface *)createSurface
{
    ISurface * surface = NULL;
    //    surface = new Cone(3, 1);
    surface = new Sphere(1.4f);
    //    surface = new Torus(1.4f, 0.3f);
    //    surface = new TrefoilKnot(1.8f);
    //    surface = new KleinBottle(0.2f);
    //    surface = new MobiusStrip(1);
    
    return surface;
}

- (void)setupVBOs
{
    ISurface * surface = [self createSurface];
    
    // Get vertice from surface.
    //
    int vBufSize = surface->GetVertexCount() * surface->GetVertexSize();
    GLfloat * vbuf = new GLfloat[vBufSize];
    surface->GenerateVertices(vbuf);
    
    // Get triangle indice from surface
    //
    _triangleIndexCount = surface->GetTriangleIndexCount();
    unsigned short * triangleBuf = new unsigned short[_triangleIndexCount];
    surface->GenerateTriangleIndices(triangleBuf);
    
    // Get line indice from surface
    //
    _lineIndexCount = surface->GetLineIndexCount();
    unsigned short * lineBuf = new unsigned short[_lineIndexCount];
    surface->GenerateLineIndices(lineBuf);
    
    // Create the VBO for the vertice.
    //
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, vBufSize * sizeof(GLfloat), vbuf, GL_STATIC_DRAW);
    
    // Create the VBO for the line indice
    //
    glGenBuffers(1, &_lineIndexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _lineIndexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, _lineIndexCount * sizeof(GLushort), lineBuf, GL_STATIC_DRAW);
    
    // Create the VBO for the triangle indice
    //
    glGenBuffers(1, &_triangleIndexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _triangleIndexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, _triangleIndexCount * sizeof(GLushort), triangleBuf, GL_STATIC_DRAW);
    
    delete [] vbuf;
    delete [] lineBuf;
    delete [] triangleBuf;
    delete surface;
}

- (void)destoryVBOs
{
    if (_triangleIndexBuffer != 0) {
        glDeleteBuffers(1, &_triangleIndexBuffer);
        _triangleIndexBuffer = 0;
    }
    
    if (_lineIndexBuffer != 0) {
        glDeleteBuffers(1, &_lineIndexBuffer);
        _lineIndexBuffer = 0;
    }
    
    if (_vertexBuffer) {
        glDeleteBuffers(1, &_vertexBuffer);
        _vertexBuffer = 0;
    }
}

- (void)updateSurfaceTransform
{
    ksMatrixLoadIdentity(&_modelViewMatrix);
    
    ksTranslate(&_modelViewMatrix, 0.0, 0.0, -7);
    
    ksRotate(&_modelViewMatrix, _rotateColorCube, 0.0, 1.0, 0.0);
    
    // Load the model-view matrix
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
}

- (void)drawSurface
{
    glEnableVertexAttribArray(_positionSlot);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), 0);
    
    // Draw the red triangles.
    //
    glVertexAttrib4f(_colorSlot, 1.0, 0.0, 0.0, 1.0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _triangleIndexBuffer);
    glDrawElements(GL_TRIANGLES, _triangleIndexCount, GL_UNSIGNED_SHORT, 0);
    
    // Draw the black lines.
    //
    glVertexAttrib4f(_colorSlot, 0.0, 0.0, 0.0, 1.0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _lineIndexBuffer);
    glDrawElements(GL_LINES, _lineIndexCount, GL_UNSIGNED_SHORT, 0);
    
    glDisableVertexAttribArray(_positionSlot);
}

- (void)render
{
    glClearColor(0.0, 1.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Setup viewport
    //
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);    
    
    [self updateSurfaceTransform];
    [self drawSurface];

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
        
        [self setupVBOs];
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
    
    [self toggleDisplayLink];
}

#pragma mark - Transform properties

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
    _rotateColorCube += displayLink.duration * 45;
    
    [self render];
}

#pragma mark

#pragma mark - Touch events

//- (void) touchesBegan: (NSSet*) touches withEvent: (UIEvent*) event
//{
//    UITouch* touch = [touches anyObject];
//    CGPoint location  = [touch locationInView: self];
//}
//
//- (void) touchesEnded: (NSSet*) touches withEvent: (UIEvent*) event
//{
//    UITouch* touch = [touches anyObject];
//    CGPoint location  = [touch locationInView: self];
//}
//
//- (void) touchesMoved: (NSSet*) touches withEvent: (UIEvent*) event
//{
//}

#pragma mark

@end
