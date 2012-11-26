//
//  ViewController.h
//  Tutorial03
//
//  Created by  on 12-11-26.
//  Copyright (c) 2012年 kesalin@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface ViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIView * controlView;
@property (nonatomic, strong) IBOutlet OpenGLView * openGLView;

- (IBAction)xSliderValueChanged:(id)sender; 
- (IBAction)ySliderValueChanged:(id)sender; 
- (IBAction)ySliderValueChanged:(id)sender; 

@end
