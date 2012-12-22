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
    CGSize _imageSize;
    CFDataRef _imageData;

}

@end

// implementation of TextureLoader
//
@implementation TextureLoader

- (void)loadPNG:(NSString *)filepath
{
    [self unload];

    NSString* fullPath = [[NSBundle mainBundle] pathForResource:filepath
                                                         ofType:@"png"];
    UIImage* uiImage = [UIImage imageWithContentsOfFile:fullPath];
    CGImageRef cgImage = uiImage.CGImage;
    _imageSize.width = CGImageGetWidth(cgImage);
    _imageSize.height = CGImageGetHeight(cgImage);
    _imageData = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
}

- (void)loadPVR:(NSString *)filepath
{
    // TODO
    //
}

- (void)unload
{
    if (_imageData != nil) {
        CFRelease(_imageData);
        _imageData = nil;
    }
}

- (CGSize)imageSize
{
    return _imageSize;
}

- (void *)imageData
{
    if (_imageData != nil) 
        return (void*) CFDataGetBytePtr(_imageData);
    return NULL;
}

@end
