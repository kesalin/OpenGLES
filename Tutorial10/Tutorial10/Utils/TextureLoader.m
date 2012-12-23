//
//  TextureLoader.m
//  Tutorial10
//
//  Created by kesalin@gmail.com kesalin on 12-12-22.
//  Copyright (c) 2012年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import "TextureLoader.h"

// Anonymous category of TextureLoader
//
@interface TextureLoader()
{
    TextureFormat _format;
    int _bitsPerComponent;
    CGSize _imageSize;
    NSData* _imageData;
}

@end

// implementation of TextureLoader
//
@implementation TextureLoader

- (void)loadImage:(NSString *)filepath
{
    [self unload];

    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString* fullPath = [resourcePath stringByAppendingPathComponent:filepath];
    
//    NSString* fullPath = [[NSBundle mainBundle] pathForResource:filepath
//                                                         ofType:@"png"];

    UIImage* uiImage = [UIImage imageWithContentsOfFile:fullPath];
    CGImageRef cgImage = uiImage.CGImage;
    _imageSize.width = CGImageGetWidth(cgImage);
    _imageSize.height = CGImageGetHeight(cgImage);
    _bitsPerComponent = 8;
    _format = TextureFormatRGBA;

    int bpp = _bitsPerComponent / 2;
    int byteCount = _imageSize.width * _imageSize.height * bpp;
    unsigned char* data = (unsigned char*) calloc(byteCount, 1);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    CGContextRef context = CGBitmapContextCreate(data,
                                                 _imageSize.width,
                                                 _imageSize.height,
                                                 _bitsPerComponent,
                                                 bpp * _imageSize.width,
                                                 colorSpace,
                                                 bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    CGRect rect = CGRectMake(0, 0, _imageSize.width, _imageSize.height);
    CGContextDrawImage(context, rect, uiImage.CGImage);
    CGContextRelease(context);
    
    _imageData = [NSData dataWithBytesNoCopy:data length:byteCount freeWhenDone:YES];
}

- (void)loadPVR:(NSString *)filepath
{
    // TODO
    //
}

- (void)unload
{
    _imageData = nil;
}

- (int)bitsPerComponent
{
    return _bitsPerComponent;
}

- (TextureFormat)textureFormat
{
    return _format;
}

- (CGSize)imageSize
{
    return _imageSize;
}

- (void *)imageData
{
    if (_imageData == nil)
        return NULL;
    
    return (void*) [_imageData bytes];
}

@end
