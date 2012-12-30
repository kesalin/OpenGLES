//
//  OpenGLView.h
//  Tutorial10
//
//  Created by kesalin@gmail.com on 12-12-24.
//  Copyright (c) 2012 年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
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
    
    GLuint _programHandle;
    GLuint _positionSlot;
    GLuint _modelViewSlot;
    GLuint _projectionSlot;
    
    // For light
    //
    GLuint _normalMatrixSlot;
    GLuint _lightPositionSlot;
    GLint _normalSlot;
    GLint _ambientSlot;
    GLint _diffuseSlot;
    GLint _specularSlot;
    GLint _shininessSlot;
    
    // For texture
    //
    NSUInteger _textureCount;
    GLuint * _textures;
    GLint _textureCoordSlot;
    GLint _samplerSlot;
    GLint _wrapMode;
    GLint _filterMode;
    NSUInteger _textureIndex;
    
    KSMatrix4 _modelViewMatrix;
    KSMatrix4 _projectionMatrix;
}

@property (nonatomic, assign) GLint wrapMode;
@property (nonatomic, assign) GLint filterMode;
@property (nonatomic, assign) NSUInteger textureIndex;

- (void)render;
- (void)cleanup;
- (void)setCurrentSurface:(int)index;

@end
