//
//  OpenGLView.m
//  Tutorial06
//
//  Created by kesalin@gmail.com on 12-12-24.
//  Copyright (c) 2012 年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import "OpenGLView.h"
#import "GLESUtils.h"
#import "ParametricEquations.h"
#import "Quaternion.h"

// Declare private members inside anonymous category
@interface OpenGLView()
{
    float _rotateColorCube;
    
    CADisplayLink * _displayLink;
    
    GLuint _vertexBuffer;
    int _vertexSize;
    
    int _triangleIndexCount;
    GLuint _triangleIndexBuffer;
    
    ivec2 _fingerStart;
    Quaternion _orientation;
    Quaternion _previousOrientation;
    KSMatrix4 _rotationMatrix;
}

- (void)setupLayer;
- (void)setupContext;
- (void)setupBuffers;
- (void)destoryBuffers;

- (void)setupProgram;
- (void)setupProjection;
- (void)setupLight;

- (void)setupVBOs:(int)surfaceType;
- (void)destoryVBOs;

- (ISurface *)createSurface:(int)surfaceType;
- (vec3) mapToSphere:(ivec2) touchpoint;

@end

@implementation OpenGLView

@synthesize lightX = _lightX;
@synthesize lightY = _lightY;
@synthesize lightZ = _lightZ;
@synthesize diffuseR = _diffuseR;
@synthesize diffuseG = _diffuseG;
@synthesize diffuseB = _diffuseB;

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
    
    // Get the attribute and uniform slot from program
    //
    _projectionSlot = glGetUniformLocation(_programHandle, "projection");
    _modelViewSlot = glGetUniformLocation(_programHandle, "modelView");
    _normalMatrixSlot = glGetUniformLocation(_programHandle, "normalMatrix");
    _lightPositionSlot = glGetUniformLocation(_programHandle, "vLightPosition");
    _ambientSlot = glGetUniformLocation(_programHandle, "vAmbientMaterial");
    _specularSlot = glGetUniformLocation(_programHandle, "vSpecularMaterial");
    _shininessSlot = glGetUniformLocation(_programHandle, "shininess");
    
    _positionSlot = glGetAttribLocation(_programHandle, "vPosition");
    _normalSlot = glGetAttribLocation(_programHandle, "vNormal");
    _diffuseSlot = glGetAttribLocation(_programHandle, "vDiffuseMaterial");
}

#pragma mark - Surface

const int SurfaceSphere = 0;
const int SurfaceCone = 1;
const int SurfaceTorus = 2;
const int SurfaceTrefoilKnot = 3;
const int SurfaceKleinBottle = 4;
const int SurfaceMobiusStrip = 5;

- (ISurface *)createSurface:(int)type
{
    ISurface * surface = NULL;
    
    if (type == SurfaceCone) {
        surface = new Cone(3, 1);
    }
    else if (type == SurfaceTorus) {
        surface = new Torus(1.5f, 0.3f);
    }
    else if (type == SurfaceTrefoilKnot) {
        surface = new TrefoilKnot(1.8f);
    }
    else if (type == SurfaceKleinBottle) {
        surface = new KleinBottle(0.2f);
    }
    else if (type == SurfaceMobiusStrip) {
        surface = new MobiusStrip(1);
    }
    else {
        surface = new Sphere(2.0f);
    }
    
    return surface;
}

- (void)setupVBOsForCube
{
    const GLfloat vertices[] = {
        -1.0f, -1.0f, 1.0f, -0.577350, -0.577350, 0.577350,
        -1.0f, 1.0f, 1.0f, -0.577350, 0.577350, 0.577350,
        1.0f, 1.0f, 1.0f, 0.577350, 0.577350, 0.577350,
        1.0f, -1.0f, 1.0f, 0.577350, -0.577350, 0.577350,
        
        1.0f, -1.0f, -1.0f, 0.577350, -0.577350, -0.577350,
        1.0f, 1.0f, -1.0f, 0.577350, 0.577350, -0.577350,
        -1.0f, 1.0f, -1.0f, -0.577350, 0.577350, -0.577350,
        -1.0f, -1.0f, -1.0f, -0.577350, -0.577350, -0.577350
    };
    
    const GLushort indices[] = {
        // Front face
        3, 2, 1, 3, 1, 0,
        
        // Back face
        7, 5, 4, 7, 6, 5,
        
        // Left face
        0, 1, 7, 7, 1, 6,
        
        // Right face
        3, 4, 5, 3, 5, 2,
        
        // Up face
        1, 2, 5, 1, 5, 6,
        
        // Down face
        0, 7, 3, 3, 7, 4
    };
    
    // Create the VBO for the vertice.
    //
    _vertexSize = 6;
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, 8 * _vertexSize * sizeof(GLfloat), vertices, GL_STATIC_DRAW);
    
    // Create the VBO for the triangle indice
    //
    _triangleIndexCount = sizeof(indices)/sizeof(indices[0]);
    glGenBuffers(1, &_triangleIndexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _triangleIndexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, _triangleIndexCount * sizeof(GLushort), indices, GL_STATIC_DRAW);
}

- (void)setupVBOs:(int)surfaceType
{
    ISurface * surface = [self createSurface:surfaceType];
    
    // Generate normals
    //
    surface->SetVertexFlags(VertexFlagsNormals);
    
    // Get vertice from surface.
    //
    _vertexSize = surface->GetVertexSize();
    int vBufSize = surface->GetVertexCount() * _vertexSize;
    GLfloat * vbuf = new GLfloat[vBufSize];
    surface->GenerateVertices(vbuf);
    
    // Get triangle indice from surface
    //
    _triangleIndexCount = surface->GetTriangleIndexCount();
    unsigned short * triangleBuf = new unsigned short[_triangleIndexCount];
    surface->GenerateTriangleIndices(triangleBuf);
    
    // Create the VBO for the vertice.
    //
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, vBufSize * sizeof(GLfloat), vbuf, GL_STATIC_DRAW);
    
    // Create the VBO for the triangle indice
    //
    glGenBuffers(1, &_triangleIndexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _triangleIndexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, _triangleIndexCount * sizeof(GLushort), triangleBuf, GL_STATIC_DRAW);
    
    delete [] vbuf;
    delete [] triangleBuf;
    delete surface;
}

- (void)destoryVBOs
{
    if (_triangleIndexBuffer != 0) {
        glDeleteBuffers(1, &_triangleIndexBuffer);
        _triangleIndexBuffer = 0;
    }
    
    if (_vertexBuffer) {
        glDeleteBuffers(1, &_vertexBuffer);
        _vertexBuffer = 0;
    }
}

#pragma mark - Draw object

-(void)setupProjection
{
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    
    // Generate a perspective matrix with a 60 degree FOV
    //
    ksMatrixLoadIdentity(&_projectionMatrix);
    float aspect = width / height;
    ksPerspective(&_projectionMatrix, 60.0, aspect, 4.0f, 10.0f);
    
    // Load projection matrix
    glUniformMatrix4fv(_projectionSlot, 1, GL_FALSE, (GLfloat*)&_projectionMatrix.m[0][0]);
    
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
}

- (void)setupLight
{
    // Set up some default material parameters.
    //
    glUniform3f(_ambientSlot, 0.04f, 0.04f, 0.04f);
    glUniform3f(_specularSlot, 0.5, 0.5, 0.5);
    glUniform1f(_shininessSlot, 50);
                 
    // Initialize various state.
    //
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_normalSlot);
    
    _lightX = 0.5;
    _lightY = 0.5;
    _lightZ = 1;
    
    _diffuseR = 0.0;
    _diffuseG = 0.5;
    _diffuseB = 1.0;
}

- (void)updateSurfaceTransform
{
    ksMatrixLoadIdentity(&_modelViewMatrix);
    
    ksTranslate(&_modelViewMatrix, 0.0, 0.0, -7);
    
    ksMatrixMultiply(&_modelViewMatrix, &_rotationMatrix, &_modelViewMatrix);
    
    // Load the model-view matrix
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
    
    // Load the normal matrix.
    // It's orthogonal, so its Inverse-Transpose is itself!
    //
    KSMatrix3 normalMatrix3;
    ksMatrix4ToMatrix3(&normalMatrix3, &_modelViewMatrix);
    glUniformMatrix3fv(_normalMatrixSlot, 1, GL_FALSE, (GLfloat*)&normalMatrix3.m[0][0]);
}

- (void)drawSurface
{
    int stride = _vertexSize * sizeof(GLfloat);
    const GLvoid* normalOffset = (const GLvoid*)(3 * sizeof(GLfloat));

    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, stride, 0);
    glVertexAttribPointer(_normalSlot, 3, GL_FLOAT, GL_FALSE, stride, normalOffset);
    
    glUniform3f(_lightPositionSlot, _lightX, _lightY, _lightZ);
    
    glVertexAttrib3f(_diffuseSlot, _diffuseR, _diffuseG, _diffuseB);
    
    // Draw the triangles.
    //
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _triangleIndexBuffer);
    glDrawElements(GL_TRIANGLES, _triangleIndexCount, GL_UNSIGNED_SHORT, 0);
}

- (void)render
{
    glClearColor(0.0f, 1.0f, 0.0f, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Setup viewport
    //
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);    
    
    [self updateSurfaceTransform];
    [self drawSurface];

    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupLayer];        
        [self setupContext];
        [self setupProgram];
        [self setupProjection];
        
        [self setupLight];
        
        ksMatrixLoadIdentity(&_rotationMatrix);
    }

    return self;
}

- (void)layoutSubviews
{
    [EAGLContext setCurrentContext:_context];
    glUseProgram(_programHandle);

    [self destoryBuffers];
    
    [self setupBuffers];
    
    //[self setupVBOs:SurfaceSphere];
    [self setupVBOsForCube];
    
    [self render];
}

#pragma mark - Touch events

- (void) touchesBegan: (NSSet*) touches withEvent: (UIEvent*) event
{
    UITouch* touch = [touches anyObject];
    CGPoint location  = [touch locationInView: self];
    
    _fingerStart = ivec2(location.x, location.y);
    _previousOrientation = _orientation;
}

- (void) touchesEnded: (NSSet*) touches withEvent: (UIEvent*) event
{
    UITouch* touch = [touches anyObject];
    CGPoint location  = [touch locationInView: self];
    ivec2 touchPoint = ivec2(location.x, location.y);
    
    vec3 start = [self mapToSphere:_fingerStart];
    vec3 end = [self mapToSphere:touchPoint];
    Quaternion delta = Quaternion::CreateFromVectors(start, end);
    _orientation = delta.Rotated(_previousOrientation);
    _orientation.ToMatrix4(&_rotationMatrix);

    [self render];
}

- (void) touchesMoved: (NSSet*) touches withEvent: (UIEvent*) event
{
    UITouch* touch = [touches anyObject];
    CGPoint location  = [touch locationInView: self];
    ivec2 touchPoint = ivec2(location.x, location.y);
    
    vec3 start = [self mapToSphere:_fingerStart];
    vec3 end = [self mapToSphere:touchPoint];
    Quaternion delta = Quaternion::CreateFromVectors(start, end);
    _orientation = delta.Rotated(_previousOrientation);
    _orientation.ToMatrix4(&_rotationMatrix);
    
    [self render];
}

- (vec3) mapToSphere:(ivec2) touchpoint
{
    ivec2 centerPoint = ivec2(self.frame.size.width/2, self.frame.size.height/2);
    float radius = self.frame.size.width/3;
    float safeRadius = radius - 1;
    
    vec2 p = touchpoint - centerPoint;
    
    // Flip the Y axis because pixel coords increase towards the bottom.
    p.y = -p.y;
    
    if (p.Length() > safeRadius) {
        float theta = atan2(p.y, p.x);
        p.x = safeRadius * cos(theta);
        p.y = safeRadius * sin(theta);
    }
    
    float z = sqrt(radius * radius - p.LengthSquared());
    vec3 mapped = vec3(p.x, p.y, z);
    return mapped / radius;
}

#pragma mark Properties

- (void)setLightX:(GLfloat)lightX
{
    _lightX = lightX;
    [self render];
}

-(GLfloat)lightX
{
    return _lightX;
}

- (void)setLightY:(GLfloat)lightY
{
    _lightY = lightY;
    [self render];
}

-(GLfloat)lightY
{
    return _lightY;
}

- (void)setLightZ:(GLfloat)lightZ
{
    _lightZ = lightZ;
    [self render];
}

-(GLfloat)lightZ
{
    return _lightZ;
}

-(void)setDiffuseR:(GLfloat)diffuseR
{
    _diffuseR = diffuseR;
    [self render];
}

-(GLfloat)diffuseR
{
    return _diffuseR;
}

-(void)setDiffuseG:(GLfloat)diffuseG
{
    _diffuseG = diffuseG;
    [self render];
}

-(GLfloat)diffuseG
{
    return _diffuseG;
}

-(void)setDiffuseB:(GLfloat)diffuseB
{
    _diffuseB = diffuseB;
    [self render];
}

-(GLfloat)diffuseB
{
    return _diffuseB;
}

@end
