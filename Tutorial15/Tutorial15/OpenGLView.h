//
//  OpenGLView.h
//  Tutorial15
//
//  Created by kesalin@gmail.com on 12-12-24.
//  Copyright (c) 2012 年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "GLESMath.h"

//
// OpenGLView interface
//
@interface OpenGLView : UIView 
{
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    GLuint _colorRenderBuffer;
    GLuint _depthRenderBuffer;
    GLuint _frameBuffer;
    
    GLuint _offscreenFrameBuffer;
    GLuint _offscreenColorRenderBuffer;
    GLuint _offscreenSurface;
    
    GLuint _programHandle;
    GLuint _positionSlot;
    GLuint _modelViewSlot;
    GLuint _projectionSlot;
    
    KSMatrix4 _modelViewMatrix;
    KSMatrix4 _projectionMatrix;
    
    // For light
    //
    GLuint _normalMatrixSlot;
    GLuint _lightPositionSlot;
    GLint _normalSlot;
    GLint _ambientSlot;
    GLint _diffuseSlot;
    GLint _specularSlot;
    GLint _shininessSlot;
    
    KSVec3 _lightPosition;
    KSColor _ambient;
    KSColor _specular;
    KSColor _diffuse;
    GLfloat _shininess;
    
    // For texture
    //
    GLint _samplerCubemapSlot;
    GLint _sampler2DSlot;
    GLint _textureModeSlot;
    GLint _textureCoordSlot;
    
    GLuint _textureCubemap;
    GLuint _texture2D;
    GLint _textureMode;
}

@property (nonatomic, assign) GLint textureMode;

- (void)render;
- (void)cleanup;

@end
