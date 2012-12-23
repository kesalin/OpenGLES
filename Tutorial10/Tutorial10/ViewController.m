//
//  ViewController.m
//  Tutorial10
//
//  Created by kesalin@gmail.com kesalin on 12-12-21.
//  Copyright (c) 2012年 http://blog.csdn.net/kesalin/. All rights reserved.
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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
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

#pragma mark - Events

-(IBAction)textureSegmentSelectionChanged:(id)sender
{
    UISegmentedControl * segment = (UISegmentedControl *)sender;
    int value = [segment selectedSegmentIndex];
    
    self.openGLView.textureIndex = value;
}

- (IBAction)wrapSegmentSelectionChanged:(id)sender
{
    UISegmentedControl * segment = (UISegmentedControl *)sender;
    int value = [segment selectedSegmentIndex];
    
    self.openGLView.wrapMode = value;
}

-(IBAction)filterSegmentSelectionChanged:(id)sender
{
    UISegmentedControl * segment = (UISegmentedControl *)sender;
    int value = [segment selectedSegmentIndex];
    
    self.openGLView.filterMode = value;
}

@end
