//
//  ViewController.m
//  Tutorial05
//
//  Created by LuoZhaohui on 12/8/12.
//  Copyright (c) 2012 年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize openGLView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self.openGLView cleanup];
    self.openGLView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (void) OnShoulderSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float currentValue = [slider value];
    
    NSLog(@" >> current shoulder is %f", currentValue);
    
    self.openGLView.rotateShoulder = currentValue;
}

- (void) OnElbowSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float currentValue = [slider value];
    
    NSLog(@" >> current elbow is %f", currentValue);
    
    self.openGLView.rotateElbow = currentValue;
}

- (IBAction) OnRotateButtonClick:(id)sender
{
    [self.openGLView toggleDisplayLink];
    
    UIButton * button = (UIButton *)sender;
    NSString * text = button.titleLabel.text;
    if ([text isEqualToString:@"Rotate"]) {
        [button setTitle: @"Stop" forState: UIControlStateNormal];
    }
    else {
        [button setTitle: @"Rotate" forState: UIControlStateNormal];
    }
}

@end
