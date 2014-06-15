//
//  PandaVideoLivePublish.m
//  HttpLiveBroadcast
//
//  Created by Leon Gordin on 6/8/14.
//  Copyright (c) 2014 Panda OS. All rights reserved.
//

#import "PandaVideoLivePublish.h"

@implementation PandaVideoLivePublish

NSString * const streamPublishApi = @"live";

@synthesize delegate;

// publish a stream on wowza via rest api
- (void) publishStream
{
    NSURL *filePublishUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?format=json", [self.apiUrl absoluteString], streamPublishApi]];
    

    self.urlRequest = [ASIFormDataRequest requestWithURL:filePublishUrl];
    self.urlRequest.delegate = self;
    
    [self.urlRequest setRequestMethod:@"POST"];
    [self.urlRequest addRequestHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
    
    // set stream name
    [self.urlRequest setPostValue:self.streamName forKey:@"streamName"];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"publishStream", @"request", nil];
    [self.urlRequest setUserInfo:userInfo];
    self.urlRequest.delegate = self;

    [self.urlRequest startAsynchronous];
    
    
    
}


#pragma mark - ASI delegate callbacks

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];

    // check which request was finished
    NSLog(@"Request finished: Response %@", responseString);

    // parse the json
    NSData *jsonData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error=nil;
    NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    NSString *result = [parsedData objectForKey:@"result"];
    if(result == nil)
    {
        result = @"failed";
    }
    
    
    // call our delegate
    [self.delegate streamPublished:request];
}

- (void)requestStarted:(ASIFormDataRequest *)request
{
    NSLog(@"Request started");
    
}

- (void)requestFailed:(ASIFormDataRequest *)request
{
    NSError *error = [request error];
    NSLog(@"Connection to %@ failed because of: %@", self.apiUrl, error);
    // call our delegate
    
//    [[self delegate] streamPublished:request];
    
}




@end
