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
@property (nonatomic, strong) IBOutlet UISlider * ambientRSlider;
@property (nonatomic, strong) IBOutlet UISlider * ambientGSlider;
@property (nonatomic, strong) IBOutlet UISlider * ambientBSlider;
@property (nonatomic, strong) IBOutlet UISlider * specularRSlider;
@property (nonatomic, strong) IBOutlet UISlider * specularGSlider;
@property (nonatomic, strong) IBOutlet UISlider * specularBSlider;
@property (nonatomic, strong) IBOutlet UISlider * shininessSlider;

- (IBAction)lightXSliderValueChanged:(id)sender;
- (IBAction)lightYSliderValueChanged:(id)sender;
- (IBAction)lightZSliderValueChanged:(id)sender;
- (IBAction)diffuseRSliderValueChanged:(id)sender;
- (IBAction)diffuseGSliderValueChanged:(id)sender;
- (IBAction)diffuseBSliderValueChanged:(id)sender;
- (IBAction)ambientRSliderValueChanged:(id)sender;
- (IBAction)ambientGSliderValueChanged:(id)sender;
- (IBAction)ambientBSliderValueChanged:(id)sender;
- (IBAction)specularRSliderValueChanged:(id)sender;
- (IBAction)specularGSliderValueChanged:(id)sender;
- (IBAction)specularBSliderValueChanged:(id)sender;
- (IBAction)shininessSliderValueChanged:(id)sender;

- (IBAction)segmentSelectionChanged:(id)sender;

@end
