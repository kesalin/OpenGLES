//
//  ViewController.h
//  Tutorial07
//
//  Created by kesalin@gmail.com on 12-12-15.
//  Copyright (c) 2012年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface ViewController : UIViewController
{
    
}

@property (nonatomic, strong) IBOutlet OpenGLView * openGLView;

@property (nonatomic, strong) IBOutlet UISlider * lightXSlider;
@property (nonatomic, strong) IBOutlet UISlider * lightYSlider;
@property (nonatomic, strong) IBOutlet UISlider * lightZSlider;
@property (nonatomic, strong) IBOutlet UISlider * diffuseRSlider;
@property (nonatomic, strong) IBOutlet UISlider * diffuseGSlider;
@property (nonatomic, strong) IBOutlet UISlider * diffuseBSlider;

- (IBAction)lightXSliderValueChanged:(id)sender;
- (IBAction)lightYSliderValueChanged:(id)sender;
- (IBAction)lightZSliderValueChanged:(id)sender;
- (IBAction)diffuseRSliderValueChanged:(id)sender;
- (IBAction)diffuseGSliderValueChanged:(id)sender;
- (IBAction)diffuseBSliderValueChanged:(id)sender;

- (IBAction)segmentSelectionChanged:(id)sender;

@end
