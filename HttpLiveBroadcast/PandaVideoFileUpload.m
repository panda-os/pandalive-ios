//
//  PandaVideoFileUpload.m
//  HttpLiveBroadcast
//
//  Created by Leon Gordin on 5/29/14.
//  Copyright (c) 2014 Panda OS. All rights reserved.
//

#import "PandaVideoFileUpload.h"

@implementation PandaVideoFileUpload

@synthesize fileUrl;
@synthesize apiUrl;

+(NSString *) getFileName:(NSURL*)fileUrl
{
    NSArray *pathComponents =[fileUrl pathComponents];
    return (NSString *) [pathComponents objectAtIndex:[pathComponents count] - 1];

}


- (void) uploadFile
{
    // read data from the file
    NSData *videoData = [NSData dataWithContentsOfFile:[self.fileUrl path]];
    
    // get the filename from fileUrl
    NSString *fileName = [PandaVideoFileUpload getFileName:self.fileUrl];
    
    self.request = [ASIFormDataRequest requestWithURL:self.apiUrl];
    [self.request setDidFinishSelector:@selector(requestFinished:)];
    [self.request setDidFailSelector:@selector(requestFailed:)];
    
    
    [self.request setDelegate:self];
    // Upload a file on disk
//    [request setFile:[self.fileUrl absoluteString] withFileName:fileName andContentType:@"video/mov"
//              forKey:@"streamchunk"];
    
    [self.request setData:videoData withFileName:fileName andContentType:@"video/mov" forKey:@"streamchunk"];
    [self.request startAsynchronous];
}


#pragma mark - private methods

// future logic to make the request more dynamic will go into these functions
- (NSMutableString*) getUrlString:(NSString*)fileName {
    NSMutableString *urlString = [[NSMutableString alloc] initWithFormat:@"name=%@&filename=%@",fileName,fileName];
    return urlString;
}

- (void) setContentType {
    [self.urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
}

- (void) setContentLength:(NSString*)postLength {
    [self.urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
}

- (void) setHTTPMethod {
    [self.urlRequest setHTTPMethod: @"POST"];
}

- (void) setCookies {
    [self.urlRequest setValue:@"XDEBUG_SESSION=PHPSTORM" forHTTPHeaderField:@"Cookie"];
}




#pragma mark - ASI delegate callbacks

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    
    NSLog(@"Request finished: Response %@", responseString);

}

- (void)requestStarted:(ASIHTTPRequest *)request
{
    NSLog(@"Request started");
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"Connection to %@ failed because of: %@", self.apiUrl, error);

}

@end
