//
//  OpenGLView.m
//  Tutorial15
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
    CADisplayLink * _displayLink;
    float _timestamp;
    float _fboTransition;
    float _theta;
    float _totalTheta;
    
    NSMutableArray * _vboArray; 
    
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

- (void)setupLights;
- (void)updateLights;

- (void)setupTextures;
- (void)destoryTextures;

- (void)setupVBOs;
- (void)destoryVBOs;

- (void)updateSurface;
- (void)drawSurface:(DrawableVBO *) vbo;

- (vec3)mapToSphere:(ivec2) touchpoint;
- (void)resetRotation;

- (void)toggleDisplayLink;
- (void)displayLinkCallback:(CADisplayLink*)displayLink;

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

- (CGSize)getFrameBufferSize
{
    int width, height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    return CGSizeMake(width, height);
}

- (void)setupBuffers
{
    ///////////////////////////////////////////////////////////////////////
    //      Setup onscreen frame buffer
    ///////////////////////////////////////////////////////////////////////
    
    // Setup color render buffer
    //
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    // Setuip frame buffer
    //
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    // Attach color render buffer and depth render buffer to frameBuffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
    
    ///////////////////////////////////////////////////////////////////////
    //      Setup offscreen frame buffer
    ///////////////////////////////////////////////////////////////////////
    
    CGSize size = [self getFrameBufferSize];
    size.width *= 2;
    size.height *= 2;
    
    // Setup color render buffer
    //
    glGenRenderbuffers(1, &_offscreenColorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _offscreenColorRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, size.width, size.height);
    
    // Setup depth render buffer
    //
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, size.width, size.height);
    
    // Setup offscreen frame buffer
    //
    glGenFramebuffers(1, &_offscreenFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _offscreenFrameBuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _offscreenColorRenderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,
                              GL_RENDERBUFFER, _depthRenderBuffer);
    
    // Create a texture object and associate it with the offscreen FBO
    //
    glGenTextures(1, &_offscreenSurface);
    glBindTexture(GL_TEXTURE_2D, _offscreenSurface);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, size.width, size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _offscreenSurface, 0);
    
    // Check FBO satus
    //
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Error: Frame buffer is not completed.");
        exit(1);
    }
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

- (void)setupVBOs
{
    if (_vboArray == nil) {
        _vboArray = [[NSMutableArray alloc] init];
        
        DrawableVBO * vbo = [DrawableVBOFactory createDrawableVBO:SurfaceSphere];
        [_vboArray addObject:vbo];
        vbo = nil;
        
        vbo = [DrawableVBOFactory createDrawableVBO:SurfaceKleinBottle];
        [_vboArray addObject:vbo];
        vbo = nil;
        
        vbo = [DrawableVBOFactory createDrawableVBO:SurfaceQuad];
        [_vboArray addObject:vbo];
        vbo = nil;
    } 
}

- (void)destoryVBOs
{
    for (DrawableVBO * vbo in _vboArray) {
        [vbo cleanup];
    }
    _vboArray = nil;
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
    _lightPosition.x = _lightPosition.y = 0.0;
    _lightPosition.z = 1.0;
    
    _ambient.r = _ambient.g = _ambient.b = 0.04f;
    _ambient.a = 0.5f;

    _specular.r = _specular.g = _specular.b = _specular.a = 0.5f;
    _diffuse.r = _diffuse.g = _diffuse.b = _diffuse.a = 0.8;
    
    _shininess = 20;
}

- (void)updateLights
{
    glUniform3f(_lightPositionSlot, _lightPosition.x, _lightPosition.y, _lightPosition.z);
    glUniform4f(_ambientSlot, _ambient.r, _ambient.g, _ambient.b, _ambient.a);
    glUniform4f(_specularSlot, _specular.r, _specular.g, _specular.b, _specular.a);
    glVertexAttrib4f(_diffuseSlot, _diffuse.r, _diffuse.g, _diffuse.b, _diffuse.a);
    glUniform1f(_shininessSlot, _shininess);
}

#pragma mark - Texture

- (void)setupTextures
{
    // Load texture for stage 0 - Cubemap
    //
	glActiveTexture(GL_TEXTURE0);
    _textureCubemap = [TextureHelper createTextureCubemap:@"tibet.jpg"];
    
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

- (void)resetRotation
{
    ksMatrixLoadIdentity(&_rotationMatrix);
    _previousOrientation.ToIdentity();
    _orientation.ToIdentity();
}

- (void)updateSurface
{
    // Load projection matrix
    //
    ksMatrixLoadIdentity(&_projectionMatrix);
    CGSize size = [self getFrameBufferSize];
    float aspect = size.width / size.height;
    ksPerspective(&_projectionMatrix, 60.0, aspect, 4.0f, 12.0f);
    
    glUniformMatrix4fv(_projectionSlot, 1, GL_FALSE, (GLfloat*)&_projectionMatrix.m[0][0]);
    
    // Load the model-view matrix
    //
    ksMatrixLoadIdentity(&_modelViewMatrix);
    ksTranslate(&_modelViewMatrix, 0.0, 0.0, -9);
    ksMatrixMultiply(&_modelViewMatrix, &_rotationMatrix, &_modelViewMatrix);
    
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
    
    // Load the normal matrix.
    // It's orthogonal, so its Inverse-Transpose is itself!
    //
    KSMatrix3 normalMatrix3;
    ksMatrix4ToMatrix3(&normalMatrix3, &_modelViewMatrix);
    glUniformMatrix3fv(_normalMatrixSlot, 1, GL_FALSE, (GLfloat*)&normalMatrix3.m[0][0]);
    
    [self updateLights];
    
    [self updateTextures];
}

- (void)drawSurface:(DrawableVBO *) vbo
{
    if (vbo == nil)
        return;
    
    int stride = [vbo vertexSize] * sizeof(GLfloat);
    const GLvoid* normalOffset = (const GLvoid*)(3 * sizeof(GLfloat));
    const GLvoid* texCoordOffset = (const GLvoid*)(6 * sizeof(GLfloat));
    
    glBindBuffer(GL_ARRAY_BUFFER, [vbo vertexBuffer]);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, stride, 0);
    glVertexAttribPointer(_normalSlot, 3, GL_FLOAT, GL_FALSE, stride, normalOffset);
    glVertexAttribPointer(_textureCoordSlot, 2, GL_FLOAT, GL_FALSE, stride, texCoordOffset);
    
    // Draw the triangles.
    //
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, [vbo triangleIndexBuffer]);
    glDrawElements(GL_TRIANGLES, [vbo triangleIndexCount], GL_UNSIGNED_SHORT, 0);
}

- (void)updateOffscreenSurface
{
    // Load projection matrix
    //
    ksMatrixLoadIdentity(&_projectionMatrix);
    ksFrustum(&_projectionMatrix, -0.5, 0.5, -0.5, 0.5, 4.0, 12.0f);
    
    glUniformMatrix4fv(_projectionSlot, 1, GL_FALSE, (GLfloat*)&_projectionMatrix.m[0][0]);
    
    // Load the model-view matrix
    //
    ksMatrixLoadIdentity(&_modelViewMatrix);
    ksTranslate(&_modelViewMatrix, 0.0, 0.0, -8);
    ksRotate(&_modelViewMatrix, _theta, 0, 1, 0);
    
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
    
    // Load the normal matrix.
    // It's orthogonal, so its Inverse-Transpose is itself!
    //
    KSMatrix3 normalMatrix3;
    ksMatrix4ToMatrix3(&normalMatrix3, &_modelViewMatrix);
    glUniformMatrix3fv(_normalMatrixSlot, 1, GL_FALSE, (GLfloat*)&normalMatrix3.m[0][0]);
    
    [self updateLights];
    
    GLint savedTextureMode = _textureMode;
    _textureMode = 1;   // texture2D
    [self updateTextures];
    _textureMode = savedTextureMode;
}

- (Boolean)isPositive
{
    return (_theta > 270 || _theta < 90);
}

- (void)render
{
    if (_context == nil)
        return;
    
    int vboIndex = 0;
    KSColor bgColor;
    if ([self isPositive]) {
        vboIndex = 0;
        _textureMode = 0;
        bgColor.r = bgColor.a = 1.0;
        bgColor.g = bgColor.b = 0.0;
    }
    else {
        vboIndex = 1;
        _textureMode = 1;
        bgColor.b = bgColor.a = 1.0;
        bgColor.r = bgColor.g = 0.0;
    }
    
    // Draw to offscreen framebuffer
    //
    glEnable(GL_DEPTH_TEST);
    DrawableVBO * vbo = [_vboArray objectAtIndex:vboIndex];

    glBindFramebuffer(GL_FRAMEBUFFER, _offscreenFrameBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _offscreenColorRenderBuffer);
    
    CGSize doubleSize = [self getFrameBufferSize];
    glViewport(0, 0, doubleSize.width, doubleSize.height);  
    
    glClearColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _texture2D);
    
    [self updateSurface];
    [self drawSurface:vbo];
    
    // Switch to onscreen framebuffer
    //
    glDisable(GL_DEPTH_TEST);
    vbo = [_vboArray objectAtIndex:2]; // quad
    
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    
    CGSize normalSize = [self getFrameBufferSize];
    glViewport(0, 0, normalSize.width, normalSize.height);

    glClearColor(0.0, 1.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _offscreenSurface);
    
    [self updateOffscreenSurface];
    [self drawSurface:vbo];

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
        
        [self setupLights];
        
        [self setupTextures];
        
        [self resetRotation];
        
        [self toggleDisplayLink];
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

    if (![self isPositive]) {
        ksMatrixInvert(&_rotationMatrix, &_rotationMatrix);
    }

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
    
    if (![self isPositive]) {
        ksMatrixInvert(&_rotationMatrix, &_rotationMatrix);
    }

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
    // If the FBO transition animation is active, update it.
    if (_fboTransition != 0) {
        _fboTransition -= displayLink.duration * 150;
        if (_fboTransition < 0)
            _fboTransition = 0;
        
        _theta = int(_totalTheta - _fboTransition) % 360;
    }
    
    // Start a new FBO transition every four seconds.
    _timestamp += displayLink.duration;
    if (_timestamp > 4 && _fboTransition == 0) {
        _totalTheta += 180;
        _fboTransition = 180;
        _timestamp = 0;
    }
    
    [self render];
}

#pragma mark - properties

- (void) setTextureMode:(GLint)textureMode
{
    _textureMode = textureMode;
    
    [self render];
}
@end
