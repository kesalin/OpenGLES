//
//  SurfaceManager.h
//  Tutorial06
//
//  Created by kesalin@gmail.com on 12-12-13.
//  Copyright (c) 2012年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SurfaceManager : NSObject

+(SurfaceManager *)instance;

- (void)setup;
- (void)destory;

- (int)vertexSize;
- (int)vertexCount;
- (int)lineIndexCount;
- (int)triangleIndexCount;

- (void)generateVertices:(float *)vertexBuf;

@end
