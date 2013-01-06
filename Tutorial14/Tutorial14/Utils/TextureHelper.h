//
//  TextureHelper.h
//
//  Created by kesalin@gmail.com kesalin on 12-12-30.
//  Copyright (c) 2012年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TextureLoader.h"

@interface TextureHelper : NSObject

+ (GLuint)createTexture:(NSString *)textureFilename isPVR:(Boolean)isPVR;
+ (GLuint)createTextureCubemap:(NSArray *)textureFilenames;
+ (void)deleteTexture:(GLuint *)textureHandle;

@end
