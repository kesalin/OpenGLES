//
//  ViewController.m
//  Tutorial11
//
//  Created by kesalin@gmail.com kesalin on 12-12-26.
//  Copyright (c) 2012年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import "ViewController.h"
#import "GLESMath.h"

@implementation ViewController

@synthesize openGLView;
@synthesize lightXSlider, lightYSlider, lightZSlider;
@synthesize diffuseRSlider, diffuseGSlider, diffuseBSlider, diffuseASlider;  
@synthesize shininessSlider;
@synthesize blendModeSlider;
@synthesize blendModeLabel;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)updateBlendModeLabel
{
    NSString * modeName = [self.openGLView currentBlendModeName];
    self.blendModeLabel.text = modeName;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.lightXSlider.value = self.openGLView.lightPosition.x;
    self.lightYSlider.value = self.openGLView.lightPosition.y;
    self.lightZSlider.value = self.openGLView.lightPosition.z;
    self.diffuseRSlider.value = self.openGLView.diffuse.r;
    self.diffuseGSlider.value = self.openGLView.diffuse.g;
    self.diffuseBSlider.value = self.openGLView.diffuse.b;
    self.diffuseASlider.value = self.openGLView.diffuse.a;
    self.shininessSlider.value = self.openGLView.shininess;
    self.blendModeSlider.value = self.openGLView.blendMode;
    
    [self updateBlendModeLabel];
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
    self.diffuseASlider = nil;
    self.shininessSlider = nil;
    self.blendModeSlider = nil;
    self.blendModeLabel = nil;
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

- (void)lightXSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    KSVec3 pos = self.openGLView.lightPosition;
    pos.x = value;
    self.openGLView.lightPosition = pos;
}

- (void)lightYSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    KSVec3 pos = self.openGLView.lightPosition;
    pos.y = value;
    self.openGLView.lightPosition = pos;
}

- (void)lightZSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    KSVec3 pos = self.openGLView.lightPosition;
    pos.z = value;
    self.openGLView.lightPosition = pos;
}

- (void)diffuseRSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    KSColor diffuse = self.openGLView.diffuse;
    diffuse.r = value;
    
    self.openGLView.diffuse = diffuse;
}

- (void)diffuseGSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    KSColor diffuse = self.openGLView.diffuse;
    diffuse.g = value;
    
    self.openGLView.diffuse = diffuse;
}

- (void)diffuseBSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    KSColor diffuse = self.openGLView.diffuse;
    diffuse.b = value;
    
    self.openGLView.diffuse = diffuse;
}

- (void)diffuseASliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    KSColor diffuse = self.openGLView.diffuse;
    diffuse.a = value;
    
    self.openGLView.diffuse = diffuse;
}

- (void)shininessSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    self.openGLView.shininess = value;
}

- (void)blendModeSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    int value = [slider value];
    [slider setValue:value];

    self.openGLView.blendMode = value;

    [self updateBlendModeLabel];
}

- (IBAction)texSegmentValueChanged:(id)sender
{
    UISegmentedControl * seg = (UISegmentedControl *)sender;
    NSUInteger value = [seg selectedSegmentIndex];
    
    self.openGLView.textureIndex = value;
}

@end
