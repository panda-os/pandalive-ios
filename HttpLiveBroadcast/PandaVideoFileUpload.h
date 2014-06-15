//
//  PandaVideoFileUpload.h
//  HttpLiveBroadcast
//
//  Created by Leon Gordin on 5/29/14.
//  Copyright (c) 2014 Panda OS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"



@protocol PandaVideoFileUploadDelegate

- (void) uploadFinished:(ASIHTTPRequest*)request;
- (void) setProgress:(float)newProgress;
- (void) uploadFailed:(ASIHTTPRequest*)request;

@end


@interface PandaVideoFileUpload : NSObject <ASIHTTPRequestDelegate,ASIProgressDelegate>

extern NSString * const fileUploadApi;


//@property (retain, nonatomic) NSURL *fileUrl;
@property (retain, nonatomic) NSURL *apiUrl;
@property (retain, nonatomic) NSMutableURLRequest *urlRequest;
@property (retain, nonatomic) NSURLConnection *urlConnection;
@property (retain, nonatomic) NSString *entryId;
@property (retain,atomic) NSMutableArray *uploadQueue;

@property (weak, nonatomic) id<PandaVideoFileUploadDelegate> delegate;
@property (weak, nonatomic) id<PandaVideoFileUploadDelegate> progressDelegate;

@property (retain, atomic) ASIFormDataRequest *request;
+(NSString*) getFileName:(NSURL*)fileUrl;


-(void) uploadFile:(NSURL *)fileUrl;

-(void) stopUpload;


@end
