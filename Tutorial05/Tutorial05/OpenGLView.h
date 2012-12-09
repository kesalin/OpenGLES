//
//  OpenGLView.h
//  Tutorial05
//
//  Created by kesalin on 12-11-24.
//  Copyright (c) 2012年 Created by kesalin@gmail.com on. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import "GLESMath.h"

@interface OpenGLView : UIView {
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    GLuint _colorRenderBuffer;
    GLuint _frameBuffer;
    
    GLuint _programHandle;
    GLuint _positionSlot;
    GLint _modelViewSlot;
    GLint _projectionSlot;
    
    KSMatrix4 _shouldModelViewMatrix;
    KSMatrix4 _elbowModelViewMatrix;
    
    KSMatrix4 _modelViewMatrix;
    KSMatrix4 _projectionMatrix;
    
    float _rotateShoulder;
    float _rotateElbow;
}

@property (nonatomic, assign) float rotateShoulder;
@property (nonatomic, assign) float rotateElbow;

- (void)render;
- (void)cleanup;

@end
