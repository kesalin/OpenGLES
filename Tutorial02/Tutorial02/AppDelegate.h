//
//  AppDelegate.h
//  Tutorial02
//
//  Created by kesalin on 12-11-25.
//  Copyright (c) 2012年 kesalin@gmail.com. All rights reserved.
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
