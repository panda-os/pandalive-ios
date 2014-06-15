//
//  PandaVideoViewController.h
//  HttpLiveBroadcast
//
//  Created by Leon Gordin on 5/25/14.
//  Copyright (c) 2014 Panda OS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PandaVideoLib.h"
#import "PandaVideoFileUpload.h"

@interface PandaVideoViewController : UIViewController <PandaVideoLibDelegate>


@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (retain, nonatomic) PandaVideoLib *videoLib;


- (IBAction)startCapture:(id)sender;

- (IBAction)stopCapture:(id)sender;

- (IBAction)flipAction:(id)sender;

- (void) captureReady;

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *flipButton;
@property (weak, nonatomic) IBOutlet UIProgressView *fileProgress;

@property (weak, nonatomic) IBOutlet UIButton *settingsButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progressView;


@end
