//
//  ViewController.m
//  Tutorial07
//
//  Created by kesalin@gmail.com on 12-12-15.
//  Copyright (c) 2012年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize openGLView;
@synthesize lightXSlider, lightYSlider, lightZSlider;
@synthesize diffuseRSlider, diffuseGSlider, diffuseBSlider;  

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
    
    self.lightXSlider.value = self.openGLView.lightX;
    self.lightYSlider.value = self.openGLView.lightY;
    self.lightZSlider.value = self.openGLView.lightZ;
    self.diffuseRSlider.value = self.openGLView.diffuseR;
    self.diffuseGSlider.value = self.openGLView.diffuseG;
    self.diffuseBSlider.value = self.openGLView.diffuseB;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [self.openGLView cleanup];
    self.openGLView = nil;
    
    self.lightXSlider = nil;
    self.lightYSlider = nil;
    self.lightZSlider = nil;
    self.diffuseRSlider = nil;
    self.diffuseGSlider = nil;
    self.diffuseBSlider = nil;
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

#pragma mark Action selector

- (void)lightXSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    self.openGLView.lightX = value;
}

- (void)lightYSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    self.openGLView.lightY = value;
}

- (void)lightZSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    self.openGLView.lightZ = value;
}

- (void)diffuseRSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    self.openGLView.diffuseR = value;
}

- (void)diffuseGSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    self.openGLView.diffuseG = value;
}

- (void)diffuseBSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    self.openGLView.diffuseB = value;
}

@end
