//
//  ViewController.h
//  Tutorial05
//
//  Created by LuoZhaohui on 12/8/12.
//  Copyright (c) 2012 年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface ViewController : UIViewController


@property (nonatomic, strong) IBOutlet OpenGLView * openGLView;
@property (nonatomic, strong) IBOutlet UISlider * shoulderSlider;
@property (nonatomic, strong) IBOutlet UISlider * elbowSlider;

- (IBAction) OnShoulderSliderValueChanged:(NSObject *)sender;
- (IBAction) OnElbowSliderValueChanged:(NSObject *)sender;

@end
