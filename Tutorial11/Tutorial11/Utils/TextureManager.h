//
//  TextureManager.h
//  Tutorial11
//
//  Created by kesalin@gmail.com kesalin on 12-12-22.
//  Copyright (c) 2012年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TextureLoader.h"

@interface TextureManager : NSObject

+(TextureManager *)instance;

-(TextureLoader *)loadImage:(NSString *)filepath;
-(TextureLoader *)loadPVR:(NSString *)filepath;
-(void)cleanup;
-(NSUInteger)textureCount;
-(TextureLoader *)textureAtIndex:(NSUInteger)index;

@end
