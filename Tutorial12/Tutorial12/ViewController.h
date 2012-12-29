//
//  ViewController.h
//  Tutorial12
//
//  Created by kesalin@gmail.com kesalin on 12-12-28.
//  Copyright (c) 2012年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface ViewController : UIViewController

@property (nonatomic, strong) IBOutlet OpenGLView * openGLView;
@property (nonatomic, strong) IBOutlet UISlider * blendModeSlider;
@property (nonatomic, strong) IBOutlet UILabel * blendModeLabel;
@property (nonatomic, strong) IBOutlet UISlider *alphaSlider;

- (IBAction)alphaSliderValueChanged:(id)sender;
- (IBAction)blendModeSliderValueChanged:(id)sender;
- (IBAction)textureSegmentValueChanged:(id)sender;

@end
