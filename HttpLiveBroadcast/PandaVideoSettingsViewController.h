//
//  PandaVideoStartViewController.h
//  HttpLiveBroadcast
//
//  Created by Leon Gordin on 6/6/14.
//  Copyright (c) 2014 Panda OS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PandaVideoLib.h"

@interface PandaVideoSettingsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *streamingServerUrl;
@property (weak, nonatomic) IBOutlet UITextField *liveStreamName;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentsView;
- (IBAction)goButtonAction:(id)sender;

@end
