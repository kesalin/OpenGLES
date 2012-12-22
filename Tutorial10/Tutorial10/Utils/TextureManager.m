//
//  TextureManager.m
//  Tutorial10
//
//  Created by kesalin@gmail.com kesalin on 12-12-22.
//  Copyright (c) 2012年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import "TextureManager.h"

// Anonymous category of TextureManager
//
@interface TextureManager()
{
    NSMutableArray * _array;
}

@end

static TextureManager * _instance = nil;

@implementation TextureManager

+(TextureManager *)instance
{
    if (_instance == nil) {
        _instance = [[TextureManager alloc] init];
    }
    return _instance;
}

-(id)init
{
    self = [super init];
    if (nil != self) {
        _array = [NSMutableArray array];
    }
    
    return self;
}

- (void)loadPNG:(NSString *)filepath
{
    TextureLoader * loader = [[TextureLoader alloc] init];
    [loader loadPNG:filepath];
    
    [_array addObject:loader];
}

-(void)cleanup
{
    for (TextureManager * loader in _array) {
        [loader cleanup];
    }
    
    [_array removeAllObjects];
    _array = nil;
}

-(TextureLoader *)textureAtIndex:(NSUInteger)index
{
    if (index < [_array count]) {
        return [_array objectAtIndex:index];
    }
    
    return nil;
}

-(NSUInteger)textureCount
{
    return [_array count];
}

@end
