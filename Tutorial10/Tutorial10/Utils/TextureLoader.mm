//
//  TextureLoader.m
//  Tutorial10
//
//  Created by kesalin@gmail.com kesalin on 12-12-22.
//  Copyright (c) 2012年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import "TextureLoader.h"
#import "PVRTTexture.h"
#import "GLESMath.h"

// Anonymous category of TextureLoader
//
@interface TextureLoader()
{
    Boolean _hasPvrHeader;
    TextureFormat _format;
    unsigned short _bitsPerComponent;
    CGSize _imageSize;
    CGSize _originalSize;
    NSData* _imageData;
    unsigned short _mipCount;
}

@end

// implementation of TextureLoader
//
@implementation TextureLoader

- (void)loadImage:(NSString *)filepath isPOT:(Boolean)isPOT
{
    [self unload];

    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString* fullPath = [resourcePath stringByAppendingPathComponent:filepath];

    UIImage* uiImage = [UIImage imageWithContentsOfFile:fullPath];
    CGImageRef cgImage = uiImage.CGImage;

    _originalSize.width = CGImageGetWidth(cgImage);
    _originalSize.height = CGImageGetHeight(cgImage);
    if (isPOT) {
        _imageSize.width = ksNextPot(_originalSize.width);
        _imageSize.height = ksNextPot(_originalSize.height);
    }
    else {
        _imageSize = _originalSize;
    }

    _bitsPerComponent = 8;
    _format = TextureFormatRGBA;
    _mipCount = 1;

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
    _hasPvrHeader = FALSE;
}

- (void)loadPVR:(NSString *)filepath isPOT:(Boolean)isPOT;
{
    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString* fullPath = [resourcePath stringByAppendingPathComponent:filepath];
    
    _imageData = [NSData dataWithContentsOfFile:fullPath];
    _hasPvrHeader = TRUE;

    PVR_Texture_Header* header = (PVR_Texture_Header*) [_imageData bytes];

    _originalSize.width = header->dwWidth;
    _originalSize.height = header->dwHeight;
    if (isPOT) {
        _imageSize.width = ksNextPot(_originalSize.width);
        _imageSize.height = ksNextPot(_originalSize.height);
    }
    else {
        _imageSize = _originalSize;
    }
    
    _mipCount = header->dwMipMapCount;
    
    bool hasAlpha = header->dwAlphaBitMask ? true : false;
    unsigned pixelType = header->dwpfFlags & PVRTEX_PIXELTYPE; 

    switch (pixelType) {
        case OGL_RGB_565:
            _format = TextureFormat565;
            break;
        case OGL_RGBA_5551:
            _format = TextureFormat5551;
            break;
        case OGL_RGBA_4444:
            _format = TextureFormatRGBA;
            _bitsPerComponent = 4;
            break;
        case OGL_PVRTC2:    
            _format = hasAlpha ? TextureFormatPvrtcRgba2 : TextureFormatPvrtcRgb2;
            break;
        case OGL_PVRTC4:
            _format = hasAlpha ? TextureFormatPvrtcRgba4 : TextureFormatPvrtcRgb4;
            break;
        default:
            NSAssert(FALSE, @"Unsupported PVR image.");
            break;
    }
}

- (void)unload
{
    _imageData = nil;
}

- (void *)imageData
{
    if (_imageData == nil)
        return NULL;
    
    if (_hasPvrHeader) {
        PVR_Texture_Header* header = (PVR_Texture_Header*) [_imageData bytes];
        char* data = (char*) [_imageData bytes];
        unsigned int headerSize = header->dwHeaderSize;
        return data + headerSize;
    }
    
    return (void*) [_imageData bytes];
}

- (unsigned short)mipCount
{
    return _mipCount;
}

- (unsigned short)bitsPerComponent
{
    return _bitsPerComponent;
}

- (TextureFormat)textureFormat
{
    return _format;
}

- (CGSize)originalSize
{
    return _originalSize;
}

- (CGSize)imageSize
{
    return _imageSize;
}

- (Boolean)isPVR
{
    return _hasPvrHeader;
}

@end
