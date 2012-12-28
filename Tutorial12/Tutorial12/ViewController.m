//
//  ViewController.m
//  Tutorial12
//
//  Created by kesalin@gmail.com kesalin on 12-12-28.
//  Copyright (c) 2012年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize openGLView;
@synthesize blendModeSlider;

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
    self.blendModeSlider.value = self.openGLView.blendMode;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [self.openGLView cleanup];
    self.openGLView = nil;
    
    self.blendModeSlider = nil;
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

#pragma mark - Properties

- (void)blendModeSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    NSUInteger value = [slider value];
    [slider setValue:value];

    self.openGLView.blendMode = value;
}

- (void)textureSegmentValueChanged:(id)sender
{
    UISegmentedControl * seg = (UISegmentedControl *)sender;
    NSUInteger value = [seg selectedSegmentIndex];
    
    self.openGLView.textureIndex = value;
}

@end
