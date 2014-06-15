//
//  PandaVideoStartViewController.m
//  HttpLiveBroadcast
//
//  Created by Leon Gordin on 6/6/14.
//  Copyright (c) 2014 Panda OS. All rights reserved.
//

#import "PandaVideoStartViewController.h"

@interface PandaVideoStartViewController ()

@end

@implementation PandaVideoStartViewController

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
    
    self.scrollView.contentSize = [self.contentsView sizeThatFits:CGSizeZero]; // step 4

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

@end
