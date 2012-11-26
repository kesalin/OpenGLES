//
//  OpenGLView.h
//  Tutorial01
//
//  Created by kesalin on 12-11-24.
//  Copyright (c) 2012年 kesalin@gmail.com. All rights reserved.
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
    GLint _mvpMatrixSlot;
    
    KSMatrix4 _mvpMatrix4;
    
    float _posX;
    float _posY;
    float _posZ;
}

@property (nonatomic, assign) float posX;
@property (nonatomic, assign) float posY;
@property (nonatomic, assign) float posZ;

@end
