//
//  TextureLoader.h
//  Tutorial10
//
//  Created by kesalin@gmail.com kesalin on 12-12-22.
//  Copyright (c) 2012年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@interface TextureLoader : NSObject

- (void)loadPNG:(NSString *)filepath;
- (void)loadPVR:(NSString *)filepath;
- (void)unload;
- (CGSize)imageSize;
- (void *)imageData;

@end
