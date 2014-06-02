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

@interface PandaVideoViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (retain, nonatomic) PandaVideoLib *videoLib;


- (IBAction)startCapture:(id)sender;

- (IBAction)stopCapture:(id)sender;

- (IBAction)flipAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *flipButton;


@end
