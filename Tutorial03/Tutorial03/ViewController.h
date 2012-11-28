//
//  ViewController.h
//  Tutorial03
//
//  Created by kesalin@gmail.com on 12-11-26.
//  Copyright (c) 2012年 Created by kesalin@gmail.com on. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface ViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIView * controlView;
@property (nonatomic, strong) IBOutlet OpenGLView * openGLView;

@property (nonatomic, strong) IBOutlet UISlider * posXSlider;
@property (nonatomic, strong) IBOutlet UISlider * posYSlider;
@property (nonatomic, strong) IBOutlet UISlider * posZSlider;
@property (nonatomic, strong) IBOutlet UISlider * scaleZSlider;
@property (nonatomic, strong) IBOutlet UISlider * rotateXSlider;

- (IBAction)xSliderValueChanged:(id)sender; 
- (IBAction)ySliderValueChanged:(id)sender; 
- (IBAction)ySliderValueChanged:(id)sender;

- (IBAction)scaleZSliderValueChanged:(id)sender; 
- (IBAction)rotateXSliderValueChanged:(id)sender;

- (IBAction)autoButtonClick:(id)sender;
- (IBAction)resetButtonClick:(id)sender;

@end
