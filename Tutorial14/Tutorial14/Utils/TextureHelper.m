//
//  TextureHelper.m
//
//  Created by kesalin@gmail.com kesalin on 12-12-30.
//  Copyright (c) 2012年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import "TextureHelper.h"

// TextureHelper anoymous category
//
@interface TextureHelper()

+ (void)setImageTexture:(TextureLoader *)loader;
+ (void)setPVRTexture:(TextureLoader *)loader;
+ (void)setTextureParameter;

@end

// TextureHelper implementation
// 
@implementation TextureHelper

+ (void)setImageTexture:(TextureLoader *)loader
{
    void* pixels = [loader imageData];
    CGSize size = [loader imageSize];
    
    GLenum format;
    TextureFormat tf = [loader textureFormat];
    switch (tf) {
        case TextureFormatGray:
            format = GL_LUMINANCE;
            break;
        case TextureFormatGrayAlpha:
            format = GL_LUMINANCE_ALPHA;
            break;
        case TextureFormatRGB:
            format = GL_RGB;
            break;
        case TextureFormatRGBA:
            format = GL_RGBA;
            break;
            
        default:
            NSLog(@"ERROR: invalid texture format! %d", tf);
            break;
    }
    
    GLenum type;
    int bitsPerComponent = [loader bitsPerComponent];
    switch (bitsPerComponent) {
        case 8:
            type = GL_UNSIGNED_BYTE;
            break;
        case 4:
            if (format == GL_RGBA) {
                type = GL_UNSIGNED_SHORT_4_4_4_4;
                break;
            }
            // fall through
        default:
            NSLog(@"ERROR: invalid texture format! %d, bitsPerComponent %d", tf, bitsPerComponent);
            break;
    }
    
    glTexImage2D(GL_TEXTURE_2D, 0, format, size.width, size.height, 0, format, type, pixels);
    
    glGenerateMipmap(GL_TEXTURE_2D);
}

+ (void)setPVRTexture:(TextureLoader *)loader
{
    unsigned char* data = (unsigned char*) [loader imageData];
    CGSize size = [loader imageSize];
    int width = size.width;
    int height = size.height;
    
    int bitsPerPixel;
    GLenum format;
    bool compressed = true;
    switch ([loader textureFormat]) {
        case TextureFormatPvrtcRgba2:
            bitsPerPixel = 2;
            format = GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG;
            break;
        case TextureFormatPvrtcRgb2:
            bitsPerPixel = 2;
            format = GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG;
            break;
        case TextureFormatPvrtcRgba4:
            bitsPerPixel = 4;
            format = GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;
            break;
        case TextureFormatPvrtcRgb4:
            bitsPerPixel = 4;
            format = GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG;
            break;
        default:
            compressed = false;
            break;
    }
    
    if (compressed) {
        for (int level = 0; level < [loader mipCount]; ++level) {
            GLsizei size = MAX(32, width * height * bitsPerPixel / 8);
            glCompressedTexImage2D(GL_TEXTURE_2D, level, format, width, height, 0, size, data);
            glGenerateMipmap(GL_TEXTURE_2D);
            
            data += size;
            width >>= 1;
            height >>= 1;
        }
    }
    else {
        GLenum type;
        switch ([loader textureFormat]) {
            case TextureFormatRGBA:
                NSAssert([loader bitsPerComponent] == 4,
                         @"Invalid bitsPerComponent for RGBA format PVR");
                format = GL_RGBA;
                type = GL_UNSIGNED_SHORT_4_4_4_4;
                bitsPerPixel = 16;
                break;
            case TextureFormat565:
                format = GL_RGB;
                type = GL_UNSIGNED_SHORT_5_6_5;
                bitsPerPixel = 16;
                break;
            case TextureFormat5551:
                format = GL_RGBA;
                type = GL_UNSIGNED_SHORT_5_5_5_1;
                bitsPerPixel = 16;
                break;
            default:
                break;
        }
        
        for (int level = 0; level < [loader mipCount]; ++level) {
            GLsizei size = width * height * bitsPerPixel / 8;
            glTexImage2D(GL_TEXTURE_2D, level, format, width, height, 0, format, type, data);
            glGenerateMipmap(GL_TEXTURE_2D);
            
            data += size;
            width >>= 1;
            height >>= 1;
        }
    }
}

+ (void)setTextureParameter
{
    // It can be GL_NICEST or GL_FASTEST or GL_DONT_CARE. GL_DONT_CARE by default.
    //
    glHint(GL_GENERATE_MIPMAP_HINT, GL_NICEST);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); 
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
}

+ (GLuint)createTexture:(NSString *)textureFile isPVR:(Boolean)isPVR
{
    TextureLoader * loader = [[TextureLoader alloc] init];
    if (isPVR) {
        [loader loadPVR:textureFile isPOT:FALSE];
    }
    else {
        [loader loadImage:textureFile isPOT:FALSE];
    }
    
    GLuint textureHandle = 0;
    
    glGenTextures(1, &textureHandle);
    glBindTexture(GL_TEXTURE_2D, textureHandle);
    
    [self setTextureParameter];
    
    if (isPVR) {
        [self setPVRTexture:loader];
    }
    else {
        [self setImageTexture:loader];
    }
    
    [loader unload];
    loader = nil;
    
    return textureHandle;
}

+ (void)deleteTexture:(GLuint *)textureHandle
{
    if (*textureHandle != 0) {
        glDeleteTextures(1, textureHandle);
        *textureHandle = 0;
    }
}

@end
