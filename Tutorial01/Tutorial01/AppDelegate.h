//
//  AppDelegate.h
//  Tutorial01
//
//  Created by  on 12-11-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
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
