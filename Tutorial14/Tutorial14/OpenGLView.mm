//
//  OpenGLView.m
//  Tutorial11
//
//  Created by kesalin@gmail.com on 12-12-24.
//  Copyright (c) 2012 年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import "OpenGLView.h"
#import "GLESUtils.h"
#import "Quaternion.h"
#import "TextureHelper.h"
#import "DrawableVBOFactory.h"

//
// OpenGLView anonymous category
//
@interface OpenGLView()
{
    NSMutableArray * _vboArray; 
    DrawableVBO * _currentVBO;
    
    ivec2 _fingerStart;
    Quaternion _orientation;
    Quaternion _previousOrientation;
    KSMatrix4 _rotationMatrix;
}

- (void)setupLayer;
- (void)setupContext;
- (void)setupBuffers;
- (void)destoryBuffer:(GLuint *)buffer;
- (void)destoryBuffers;

- (void)setupProgram;
- (void)getSlotsFromProgram;
- (void)setupProjection;

- (void)setupLights;
- (void)updateLights;

- (void)setupTextures;
- (void)destoryTextures;

- (void)setupVBOs;
- (void)destoryVBOs;

- (void)updateSurface;
- (void)drawSurface;

- (vec3)mapToSphere:(ivec2) touchpoint;
- (void)resetRotation;

@end

//
// OpenGLView implementation
//
@implementation OpenGLView

@synthesize textureMode = _textureMode;

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
    // Setup color render buffer
    //
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    // Setup depth render buffer
    //
    int width, height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    
    // Create a depth buffer that has the same size as the color buffer.
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
    
    // Setup frame buffer
    //
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    // Attach color render buffer and depth render buffer to frameBuffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,
                              GL_RENDERBUFFER, _depthRenderBuffer);
    
    // Set color render buffer as current render buffer
    //
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)destoryBuffer:(GLuint *)buffer
{
    if (buffer && *buffer != 0) {
        glDeleteRenderbuffers(1, buffer);
        *buffer = 0;
    }
}

- (void)destoryBuffers
{
    [self destoryBuffer: &_depthRenderBuffer];
    [self destoryBuffer: &_colorRenderBuffer];
    [self destoryBuffer: &_frameBuffer];
}

- (void)cleanup
{   
    [self destoryTextures];

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
    
    [self getSlotsFromProgram];
}

#pragma mark - Surface

- (void)setCurrentSurface:(int)index
{
    index = index % [_vboArray count];
    _currentVBO = [_vboArray objectAtIndex:index];
    
    [self resetRotation];

    [self render];
}

- (void)setupVBOs
{
    if (_vboArray == nil) {
        _vboArray = [[NSMutableArray alloc] init];
        
        DrawableVBO * vbo = [DrawableVBOFactory createDrawableVBO:SurfaceSphere];
        [_vboArray addObject:vbo];
        vbo = nil;
        
        vbo = [DrawableVBOFactory createDrawableVBO:SurfaceCube];
        [_vboArray addObject:vbo];
        vbo = nil;
        
        vbo = [DrawableVBOFactory createDrawableVBO:SurfaceKleinBottle];
        [_vboArray addObject:vbo];
        vbo = nil;
        
        [self setCurrentSurface:0]; // Change model
    } 
}

- (void)destoryVBOs
{
    for (DrawableVBO * vbo in _vboArray) {
        [vbo cleanup];
    }
    _vboArray = nil;
    
    _currentVBO = nil;
}

#pragma mark - Light

- (void)setupLights
{
    // Initialize various state.
    //
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_normalSlot);
    
    // Set up some default material parameters.
    //
    _lightPosition.x = _lightPosition.y = 1.0;
    _lightPosition.z = 10.0;
    
    _ambient.r = _ambient.g = _ambient.b = 0.04f;
    _ambient.a = 0.5f;

    _specular.r = _specular.g = _specular.b = _specular.a = 0.5f;
    _diffuse.r = _diffuse.g = _diffuse.b = _diffuse.a = 0.8;
    
    _shininess = 20;
}

- (void)updateLights
{
    glUniform3f(_eyePositionSlot, _eyePosition.x, _eyePosition.y, _eyePosition.z);
    glUniform3f(_lightPositionSlot, _lightPosition.x, _lightPosition.y, _lightPosition.z);
    glUniform4f(_ambientSlot, _ambient.r, _ambient.g, _ambient.b, _ambient.a);
    glUniform4f(_specularSlot, _specular.r, _specular.g, _specular.b, _specular.a);
    glVertexAttrib4f(_diffuseSlot, _diffuse.r, _diffuse.g, _diffuse.b, _diffuse.a);
    glUniform1f(_shininessSlot, _shininess);
}

#pragma mark - Texture

- (void)setupTextures
{
    NSArray * textureFilenames = [NSArray arrayWithObjects:
                                  @"right.png", @"left.png", 
                                  @"sky.png", @"ground.png",
                                  @"front.png", @"back.png",
                                  nil];
    
    // Load texture for stage 0 - Cubemap
    //
	glActiveTexture(GL_TEXTURE0);
    _textureCubemap = [TextureHelper createTextureCubemap:textureFilenames];
    
    // Load texture for stage 1 - 2D
    //
    glActiveTexture(GL_TEXTURE1);
    _texture2D = [TextureHelper createTexture:@"wooden.png" isPVR:FALSE];
    
    glUniform1i(_samplerCubemapSlot, 0);
    glUniform1i(_sampler2DSlot, 1);
    
    glEnableVertexAttribArray(_textureCoordSlot);   // Enable texture coord
    
    _textureMode = 0;   // default cube map
}

- (void)updateTextures
{
    glUniform1i(_textureModeSlot, _textureMode);
}

- (void)destoryTextures
{
    [TextureHelper deleteTexture:&_textureCubemap];
    [TextureHelper deleteTexture:&_texture2D];
}

#pragma mark - Draw object

- (void)getSlotsFromProgram
{
    // Get the attribute and uniform slot from program
    //
    _projectionSlot = glGetUniformLocation(_programHandle, "projection");
    _modelViewSlot = glGetUniformLocation(_programHandle, "modelView");
    _normalMatrixSlot = glGetUniformLocation(_programHandle, "normalMatrix");
    _modelSlot = glGetUniformLocation(_programHandle, "model");
    _eyePositionSlot = glGetUniformLocation(_programHandle, "eyePosition");
    
    _lightPositionSlot = glGetUniformLocation(_programHandle, "vLightPosition");
    _ambientSlot = glGetUniformLocation(_programHandle, "vAmbientMaterial");
    _specularSlot = glGetUniformLocation(_programHandle, "vSpecularMaterial");
    _shininessSlot = glGetUniformLocation(_programHandle, "shininess");
    
    _positionSlot = glGetAttribLocation(_programHandle, "vPosition");
    _normalSlot = glGetAttribLocation(_programHandle, "vNormal");
    _diffuseSlot = glGetAttribLocation(_programHandle, "vDiffuseMaterial");

    _textureModeSlot = glGetUniformLocation(_programHandle, "textureMode");
    _samplerCubemapSlot = glGetUniformLocation(_programHandle, "samplerForCube");
    _sampler2DSlot = glGetUniformLocation(_programHandle, "samplerFor2D");
    _textureCoordSlot = glGetAttribLocation(_programHandle, "vTextureCoord");
}

-(void)setupProjection
{
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    
    // Generate a perspective matrix with a 60 degree FOV
    //
    ksMatrixLoadIdentity(&_projectionMatrix);
    float aspect = width / height;
    ksPerspective(&_projectionMatrix, 60.0, aspect, 4.0f, 12.0f);
    
    // Load projection matrix
    glUniformMatrix4fv(_projectionSlot, 1, GL_FALSE, (GLfloat*)&_projectionMatrix.m[0][0]);
    
    // Generate a view matrix
    //
    _eyePosition.x = _eyePosition.y = 0.0;
    _eyePosition.z = 1.0;
    KSVec3 target = {0.0, 0.0, -1};
    KSVec3 up = {0.0, 1.0, 0};
    ksMatrixLoadIdentity(&_viewBaseMatrix);
    ksLookAt(&_viewBaseMatrix, &_eyePosition, &target, &up);
    
    // Initialize states
    //
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
}

- (void)resetRotation
{
    ksMatrixLoadIdentity(&_rotationMatrix);
    _previousOrientation.ToIdentity();
    _orientation.ToIdentity();
}

- (void)updateSurface
{
    // Model matrix
    //
    KSMatrix4 modelMatrix;
    ksMatrixLoadIdentity(&modelMatrix);
    ksMatrixMultiply(&modelMatrix, &_rotationMatrix, &modelMatrix); // Rotate model
    
    KSMatrix3 modelMatrix3;
    ksMatrix4ToMatrix3(&modelMatrix3, &modelMatrix);
    glUniformMatrix3fv(_modelSlot, 1, GL_FALSE, (GLfloat*)&modelMatrix3.m[0][0]);

    // View matrix
    //
    KSMatrix4 viewMatrix;
    ksCopyMatrix4(&viewMatrix, &_viewBaseMatrix);
    ksTranslate(&viewMatrix, 0.0, 0.0, -9);
    
    //ksMatrixMultiply(&viewMatrix, &_rotationMatrix, &viewMatrix); // Rotate camera
    
    
    // Model-View matrix
    //
    KSMatrix4 modelViewMatrix;
    ksMatrixLoadIdentity(&modelViewMatrix);
    ksMatrixMultiply(&modelViewMatrix, &modelMatrix, &viewMatrix);
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat*)&modelViewMatrix.m[0][0]);
    
    // Load the normal matrix.
    // It's orthogonal, so its Inverse-Transpose is itself!
    //
    KSMatrix3 normalMatrix3;
    ksMatrix4ToMatrix3(&normalMatrix3, &modelViewMatrix);
    glUniformMatrix3fv(_normalMatrixSlot, 1, GL_FALSE, (GLfloat*)&normalMatrix3.m[0][0]);
    
    [self updateLights];
    
    [self updateTextures];
}

- (void)drawSurface
{
    if (_currentVBO == nil)
        return;
    
    int stride = [_currentVBO vertexSize] * sizeof(GLfloat);
    const GLvoid* normalOffset = (const GLvoid*)(3 * sizeof(GLfloat));
    const GLvoid* texCoordOffset = (const GLvoid*)(6 * sizeof(GLfloat));
    
    glBindBuffer(GL_ARRAY_BUFFER, [_currentVBO vertexBuffer]);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, stride, 0);
    glVertexAttribPointer(_normalSlot, 3, GL_FLOAT, GL_FALSE, stride, normalOffset);
    glVertexAttribPointer(_textureCoordSlot, 2, GL_FLOAT, GL_FALSE, stride, texCoordOffset);
    
    // Draw the triangles.
    //
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, [_currentVBO triangleIndexBuffer]);
    glDrawElements(GL_TRIANGLES, [_currentVBO triangleIndexCount], GL_UNSIGNED_SHORT, 0);
}

- (void)render
{
    if (_context == nil)
        return;
    
    glClearColor(0.0f, 1.0f, 0.0f, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Setup viewport
    //
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);    
    
    [self updateSurface];
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
        
        [self setupLights];
        
        [self setupTextures];
        
        [self resetRotation];
    }

    return self;
}

- (void)layoutSubviews
{
    [EAGLContext setCurrentContext:_context];
    glUseProgram(_programHandle);

    [self destoryBuffers];
    
    [self setupBuffers];
    
    [self setupVBOs];
    
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

#pragma mark - properties

- (void) setTextureMode:(GLint)textureMode
{
    _textureMode = textureMode;
    
    [self render];
}
@end
