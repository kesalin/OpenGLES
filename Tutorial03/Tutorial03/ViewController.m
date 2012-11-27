//
//  ViewController.m
//  Tutorial03
//
//  Created by kesalin@gmail.com on 12-11-26.
//  Copyright (c) 2012年 Created by kesalin@gmail.com on. All rights reserved.
//

#import "ViewController.h"

@interface ViewController()

- (void)resetControls;

@end 

@implementation ViewController

@synthesize controlView, openGLView;
@synthesize posXSlider, posYSlider, posZSlider;
@synthesize scaleYSlider, rotateZSlider;

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
    
    [self resetControls];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self.openGLView cleanup];
    self.openGLView = nil;
    
    self.posXSlider = nil;
    self.posYSlider = nil;
    self.posZSlider = nil;
    self.scaleYSlider = nil;
    self.rotateZSlider = nil;
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

- (IBAction)scaleYSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float currentValue = [slider value];
    
    openGLView.scaleY = currentValue;
    
    NSLog(@" >> current y scale is %f", currentValue);
}

- (IBAction)rotateZSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float currentValue = [slider value];
    
    openGLView.rotateZ = currentValue;
    
    NSLog(@" >> current z rotation is %f", currentValue);   
}

- (IBAction)autoButtonClick:(id)sender
{
    
}

- (IBAction)resetButtonClick:(id)sender
{
    [openGLView resetTransform];
    [openGLView render];
    
    [self resetControls];
}

- (void)resetControls
{
    [posXSlider setValue:self.openGLView.posX];
    [posYSlider setValue:self.openGLView.posY];
    [posZSlider setValue:self.openGLView.posZ];
    
    [scaleYSlider setValue:self.openGLView.scaleY];
    [rotateZSlider setValue:self.openGLView.rotateZ];
}

@end
