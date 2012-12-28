//
//  ViewController.h
//  Tutorial11
//
//  Created by kesalin@gmail.com kesalin on 12-12-26.
//  Copyright (c) 2012年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface ViewController : UIViewController

@property (nonatomic, strong) IBOutlet OpenGLView * openGLView;

@property (nonatomic, strong) IBOutlet UISlider * lightXSlider;
@property (nonatomic, strong) IBOutlet UISlider * lightYSlider;
@property (nonatomic, strong) IBOutlet UISlider * lightZSlider;
@property (nonatomic, strong) IBOutlet UISlider * diffuseRSlider;
@property (nonatomic, strong) IBOutlet UISlider * diffuseGSlider;
@property (nonatomic, strong) IBOutlet UISlider * diffuseBSlider;
@property (nonatomic, strong) IBOutlet UISlider * diffuseASlider;
@property (nonatomic, strong) IBOutlet UISlider * shininessSlider;
@property (nonatomic, strong) IBOutlet UISlider * blendModeSlider;
@property (nonatomic, strong) IBOutlet UILabel * blendModeLabel;

- (IBAction)lightXSliderValueChanged:(id)sender;
- (IBAction)lightYSliderValueChanged:(id)sender;
- (IBAction)lightZSliderValueChanged:(id)sender;
- (IBAction)diffuseRSliderValueChanged:(id)sender;
- (IBAction)diffuseGSliderValueChanged:(id)sender;
- (IBAction)diffuseBSliderValueChanged:(id)sender;
- (IBAction)diffuseASliderValueChanged:(id)sender;
- (IBAction)shininessSliderValueChanged:(id)sender;
- (IBAction)blendModeSliderValueChanged:(id)sender;
- (IBAction)texSegmentValueChanged:(id)sender;

@end
