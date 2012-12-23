//
//  ViewController.h
//  Tutorial10
//
//  Created by kesalin@gmail.com kesalin on 12-12-21.
//  Copyright (c) 2012年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface ViewController : UIViewController
{
}

@property (nonatomic, strong) IBOutlet OpenGLView * openGLView;

-(IBAction)textureSegmentSelectionChanged:(id)sender;
-(IBAction)wrapSegmentSelectionChanged:(id)sender;
-(IBAction)filterSegmentSelectionChanged:(id)sender;

@end
