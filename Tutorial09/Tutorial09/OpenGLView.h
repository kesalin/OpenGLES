//
//  OpenGLView.h
//  Tutorial07
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
// DrawableVBO interface
//
@interface DrawableVBO : NSObject

@property (nonatomic, assign) GLuint vertexBuffer;
@property (nonatomic, assign) GLuint lineIndexBuffer;
@property (nonatomic, assign) GLuint triangleIndexBuffer;
@property (nonatomic, assign) int vertexSize;
@property (nonatomic, assign) int lineIndexCount;
@property (nonatomic, assign) int triangleIndexCount;

- (void) cleanup;

@end

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
    GLuint _normalMatrixSlot;
    GLuint _lightPositionSlot;
    
    GLint _normalSlot;
    GLint _ambientSlot;
    GLint _diffuseSlot;
    GLint _specularSlot;
    GLint _shininessSlot;
    
    KSMatrix4 _modelViewMatrix;
    KSMatrix4 _projectionMatrix;
    
    GLfloat _lightX;
    GLfloat _lightY;
    GLfloat _lightZ;
    
    GLfloat _diffuseR;
    GLfloat _diffuseG;
    GLfloat _diffuseB;
}

- (void)render;
- (void)cleanup;
- (void)setCurrentSurface:(int)index;

@property (nonatomic, assign) GLfloat lightX;
@property (nonatomic, assign) GLfloat lightY;
@property (nonatomic, assign) GLfloat lightZ;
@property (nonatomic, assign) GLfloat diffuseR;
@property (nonatomic, assign) GLfloat diffuseG;
@property (nonatomic, assign) GLfloat diffuseB;

@end
