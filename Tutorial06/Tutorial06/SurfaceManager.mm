//
//  SurfaceManager.m
//  Tutorial06
//
//  Created by kesalin@gmail.com on 12-12-13.
//  Copyright (c) 2012年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import "SurfaceManager.h"
#import "ParametricEquations.h"

@interface SurfaceManager()
{
    ISurface * _surface;
}
@end

static SurfaceManager * _instance;

@implementation SurfaceManager

+(SurfaceManager *)instance
{
    if (_instance == nil) {
        _instance = [[SurfaceManager alloc] init];
    }
    
    return _instance;
}

-(id)init
{
    self = [super init];
    if (self != nil) {
    }

    return self;
}

- (void)setup
{
    if (_surface == NULL) {
        //    surface = new Cone(3, 1);
        _surface = new Sphere(1.4f);
        //    surface = new Torus(1.4f, 0.3f);
        //    surface = new TrefoilKnot(1.8f);
        //    surface = new KleinBottle(0.2f);
        //    surface = new MobiusStrip(1);
    }
    
}

- (void)destory
{
    if (_surface != NULL) {
        delete _surface;
        _surface = NULL;
    }
}

- (int)vertexSize
{
    if (_surface != NULL) {
        return _surface->GetVertexSize();
    }
    
    return 0;
}

- (int)vertexCount
{
    if (_surface != NULL) {
        return _surface->GetVertexCount();
    }
    
    return 0;
}

- (int)lineIndexCount
{
    if (_surface != NULL) {
        return _surface->GetLineIndexCount();
    }

    return 0;
}

- (int)triangleIndexCount
{
    if (_surface != NULL) {
        return _surface->GetTriangleIndexCount();
    }
    
    return 0;
}

- (void)GenerateVertices:(float *)vertexBuf
{
    if (_surface != NULL) {
        _surface->GenerateVertices(vertexBuf);
    }
}

@end
