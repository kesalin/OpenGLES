//
//  TextureLoader.h
//
//  Created by kesalin@gmail.com kesalin on 12-12-22.
//  Copyright (c) 2012年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

typedef enum TextureFormat {
    TextureFormatGray,
    TextureFormatGrayAlpha,
    TextureFormatRGB,
    TextureFormatRGBA,
    TextureFormatPvrtcRgb2,
    TextureFormatPvrtcRgba2,
    TextureFormatPvrtcRgb4,
    TextureFormatPvrtcRgba4,
    TextureFormat565,
    TextureFormat5551,
} TextureFormat;

@interface TextureLoader : NSObject

- (void)loadImage:(NSString *)filepath isPOT:(Boolean)isPOT;
- (void)loadPVR:(NSString *)filepath isPOT:(Boolean)isPOT;
- (void)unload;

- (unsigned short)bitsPerComponent;
- (TextureFormat)textureFormat;
- (CGSize)imageSize;
- (CGSize)originalSize;
- (void *)imageData;
- (unsigned short)mipCount;
- (Boolean)isPVR;
@end
