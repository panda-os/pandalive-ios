//
//  PandaVideoFileUpload.m
//  HttpLiveBroadcast
//
//  Created by Leon Gordin on 5/29/14.
//  Copyright (c) 2014 Panda OS. All rights reserved.
//

#import "PandaVideoFileUpload.h"

@implementation PandaVideoFileUpload

NSString * const fileUploadApi = @"livefile";


//@synthesize fileUrl;
@synthesize apiUrl;
@synthesize delegate;
@synthesize progressDelegate;



+(NSString *) getFileName:(NSURL*)fileUrl
{
    NSArray *pathComponents =[fileUrl pathComponents];
    return (NSString *) [pathComponents objectAtIndex:[pathComponents count] - 1];

}


- (void) uploadFile:(NSURL*)fileUrl
{
    // read data from the file
    NSData *videoData = [NSData dataWithContentsOfFile:[fileUrl path]];
    
    // get the filename from fileUrl
    NSString *fileName = [PandaVideoFileUpload getFileName:fileUrl];
    
    NSURL *fileUploadUrl = [NSURL
                            URLWithString:[NSString
                                           stringWithFormat:@"%@/%@?format=json&entryId=%@",
                                           [self.apiUrl absoluteString],
                                           fileUploadApi,
                                           self.entryId]
                            ];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:fileUploadUrl];
    [request setDidFinishSelector:@selector(requestFinished:)];
    [request setDidFailSelector:@selector(requestFailed:)];
    
    
    [request setDelegate:self];
    [request setUploadProgressDelegate:self];
    
    [request setUserInfo:[NSDictionary dictionaryWithObject:fileName forKey:@"fileName"]];
    [request setRequestMethod:@"POST"];


    
    // Upload a file on disk
    
    [request setData:videoData withFileName:fileName andContentType:@"video/mov" forKey:@"streamchunk"];
    
    // log file size
    NSError *attributesError = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[fileUrl path] error:&attributesError];
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    long long fileSize = [fileSizeNumber longLongValue];
    NSLog(@"File size for upload: %lld", fileSize);
    
    [request setTimeOutSeconds:20];
    [request startAsynchronous];
    
    [self.uploadQueue addObject:request];

    
}


- (void) stopUpload
{
    for (id request in self.uploadQueue) {
        if([request respondsToSelector:@selector(cancel)] )
        {
            [request cancel];
        }
    }}


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
//    [self.urlRequest setValue:@"XDEBUG_SESSION=PHPSTORM" forHTTPHeaderField:@"Cookie"];
}




#pragma mark - ASI delegate callbacks

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    
    NSLog(@"Request finished: Response %@", responseString);
    
    // call our delegate
    [self.delegate uploadFinished:request];
    [self.uploadQueue removeObject:request];

}

- (void)requestStarted:(ASIFormDataRequest *)request
{
    NSLog(@"Request started");
    
}

- (void)requestFailed:(ASIFormDataRequest *)request
{
    NSError *error = [request error];
    NSLog(@"Connection to %@ failed because of: %@", self.apiUrl, error);
    
    [[self delegate] uploadFailed:request];
    [self.uploadQueue removeObject:request];
  //  }

}


- (void)setProgress:(float)newProgress
{
//    NSLog(@"Progress value: %f", newProgress);
    [self.progressDelegate setProgress:newProgress];
    
}

- (void)setMaxValue:(double)newMax
{
    NSLog(@"Max value: %f", newMax);
}


@end
