//
//  PandaVideoStartViewController.m
//  HttpLiveBroadcast
//
//  Created by Leon Gordin on 6/6/14.
//  Copyright (c) 2014 Panda OS. All rights reserved.
//

#import "PandaVideoSettingsViewController.h"

@interface PandaVideoSettingsViewController ()

@end

@implementation PandaVideoSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.streamingServerUrl.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"apiUrl"];

    self.liveStreamName.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"streamName"];
    
    self.scrollView.contentSize = self.contentsView.bounds.size;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)goButtonAction:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.streamingServerUrl.text forKey:@"apiUrl"];
    [[NSUserDefaults standardUserDefaults] setObject:self.liveStreamName.text forKey:@"streamName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
@end
