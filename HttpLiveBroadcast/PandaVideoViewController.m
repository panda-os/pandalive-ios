//
//  PandaVideoViewController.m
//  HttpLiveBroadcast
//
//  Created by Leon Gordin on 5/25/14.
//  Copyright (c) 2014 Panda OS. All rights reserved.
//

#import "PandaVideoViewController.h"


@interface PandaVideoViewController ()  

@end

@implementation PandaVideoViewController 

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    self.videoLib = [PandaVideoLib getInstance];
    self.videoLib.delegate = self;
    
    [self.videoLib embedIntoView:self.cameraView];
    
    // hide stop button
    self.stopButton.hidden = YES;
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    
    
    // Dispose of any resources that can be recreated.
}


- (IBAction)startCapture:(id)sender {
    // show stop button and hide start button
    self.startButton.hidden = YES;
    self.flipButton.hidden = YES;
    self.stopButton.hidden = NO;
    
    [self.videoLib startRecordingSession];
}
- (IBAction)stopCapture:(id)sender {
    // show start button and hide stop button
    self.stopButton.hidden = YES;
    self.flipButton.hidden = NO;
    self.startButton.hidden = NO;

    [self.videoLib endRecordingSession];
}

- (IBAction)flipAction:(id)sender {
    [self.videoLib flipCamera];
}
@end
