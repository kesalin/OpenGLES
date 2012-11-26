//
//  ViewController.m
//  Tutorial03
//
//  Created by  on 12-11-26.
//  Copyright (c) 2012年 kesalin@gmail.com. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize controlView, openGLView;

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
    
    self.openGLView = nil;
    self.controlView = nil;
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

- (IBAction)xSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float currentValue = [slider value];
    
    openGLView.posX = currentValue;

    NSLog(@" >> current x is %f", currentValue);
}

- (IBAction)ySliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float currentValue = [slider value];
    
    openGLView.posY = currentValue;
    
    NSLog(@" >> current y is %f", currentValue);
}

- (IBAction)zSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float currentValue = [slider value];
    
    openGLView.posZ = currentValue;
    
    NSLog(@" >> current z is %f", currentValue);
}

@end
