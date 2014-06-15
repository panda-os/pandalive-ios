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
    self.startButton.hidden = NO;
    self.progressView.hidden = YES;
    self.fileProgress.hidden = YES;
    
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];   //it hides
    
    // set the api url and the stream name
    [self.videoLib setApiUrl:[[NSUserDefaults standardUserDefaults] stringForKey:@"apiUrl"]];
    [self.videoLib setStreamName:[[NSUserDefaults standardUserDefaults] stringForKey:@"streamName"]];

    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];    // it shows
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
    self.settingsButton.hidden = YES;
    self.progressView.hidden = NO;
    // create the live entry in Kaltura
    [self.videoLib initStream];
    // callback in captureReady

    
}
- (IBAction)stopCapture:(id)sender {
    // show start button and hide stop button
    self.stopButton.hidden = YES;
    self.flipButton.hidden = NO;
    self.startButton.hidden = NO;
    self.settingsButton.hidden = NO;
    self.fileProgress.hidden = YES;

    [self.videoLib endRecordingSession];
}

- (IBAction)flipAction:(id)sender {
    [self.videoLib flipCamera];
}

#pragma mark - capture ready callback
- (void) captureReady{
    self.progressView.hidden = YES;
    self.stopButton.hidden = NO;
    self.fileProgress.hidden = NO;

    [self.videoLib startRecordingSession];
}

#pragma mark - set progress callback
- (void) setProgress:(float)progress{
    if(progress == 1)
    {
        [self.fileProgress setProgress:0];
    }
    else
    {
        [self.fileProgress setProgress:progress];
    }
}

@end
