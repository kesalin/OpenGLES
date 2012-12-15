//
//  ViewController.h
//  Tutorial06
//
//  Created by kesalin@gmail.com on 12-12-13.
//  Copyright (c) 2012年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface ViewController : UIViewController
{
    OpenGLView * _openGLView;
}

@property (nonatomic, strong) IBOutlet OpenGLView * openGLView;

- (IBAction)segmentSelectionChanged:(id)sender;

@end
