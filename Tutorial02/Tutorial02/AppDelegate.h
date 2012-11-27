//
//  AppDelegate.h
//  Tutorial02
//
//  Created by kesalin@gmail.com on 12-11-25.
//  Copyright (c) 2012年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    OpenGLView* _glView;
}

@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (strong, retain) IBOutlet OpenGLView *glView;

@end
