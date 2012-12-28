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
@synthesize ambientRSlider, ambientGSlider, ambientBSlider;
@synthesize specularRSlider, specularGSlider, specularBSlider;
@synthesize shininessSlider;

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
    
    self.lightXSlider.value = self.openGLView.lightPosition.x;
    self.lightYSlider.value = self.openGLView.lightPosition.y;
    self.lightZSlider.value = self.openGLView.lightPosition.z;
    self.diffuseRSlider.value = self.openGLView.diffuse.r;
    self.diffuseGSlider.value = self.openGLView.diffuse.g;
    self.diffuseBSlider.value = self.openGLView.diffuse.b;
    self.ambientRSlider.value = self.openGLView.ambient.r;
    self.ambientGSlider.value = self.openGLView.ambient.g;
    self.ambientBSlider.value = self.openGLView.ambient.b;
    self.specularRSlider.value = self.openGLView.specular.r;
    self.specularGSlider.value = self.openGLView.specular.g;
    self.specularBSlider.value = self.openGLView.specular.b;
    self.shininessSlider.value = self.openGLView.shininess;
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
    self.ambientRSlider = nil;
    self.ambientGSlider = nil;
    self.ambientBSlider = nil;
    self.specularRSlider = nil;
    self.specularGSlider = nil;
    self.specularBSlider = nil;
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

// light position
//
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

// diffuse
//
- (void)diffuseRSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    KSColor color = self.openGLView.diffuse;
    color.r = value;
    self.openGLView.diffuse = color;
}

- (void)diffuseGSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    KSColor color = self.openGLView.diffuse;
    color.g = value;
    self.openGLView.diffuse = color;
}

- (void)diffuseBSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    KSColor color = self.openGLView.diffuse;
    color.b = value;
    self.openGLView.diffuse = color;
}

// ambient
//
- (void)ambientRSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    KSColor color = self.openGLView.ambient;
    color.r = value;
    self.openGLView.ambient = color;
}

- (void)ambientGSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    KSColor color = self.openGLView.ambient;
    color.g = value;
    self.openGLView.ambient = color;
}

- (void)ambientBSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    KSColor color = self.openGLView.ambient;
    color.b = value;
    self.openGLView.ambient = color;
}

// specular
//
- (void)specularRSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    KSColor color = self.openGLView.specular;
    color.r = value;
    self.openGLView.specular = color;
}

- (void)specularGSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    KSColor color = self.openGLView.specular;
    color.g = value;
    self.openGLView.specular = color;
}

- (void)specularBSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    KSColor color = self.openGLView.specular;
    color.b = value;
    self.openGLView.specular = color;
}

// shininess
//
- (void)shininessSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float value = [slider value];
    
    self.openGLView.shininess = value;
}

- (void)segmentSelectionChanged:(id)sender
{
    UISegmentedControl * segment = (UISegmentedControl *)sender;
    int index = [segment selectedSegmentIndex];
    
    [self.openGLView setCurrentSurface:index];
}
@end
