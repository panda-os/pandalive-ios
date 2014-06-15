//
//  PandaVideoLivePublish.h
//  HttpLiveBroadcast
//
//  Created by Leon Gordin on 6/8/14.
//  Copyright (c) 2014 Panda OS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"


@protocol PandaVideoLivePublishDelegate

- (void) streamPublished:(ASIHTTPRequest*)request;


@end


@interface PandaVideoLivePublish : NSObject <ASIHTTPRequestDelegate>

extern NSString * const streamPublishApi;

@property (weak, nonatomic) id<PandaVideoLivePublishDelegate> delegate;



@property (retain, nonatomic) NSURL *apiUrl;
@property (retain, nonatomic) ASIFormDataRequest *urlRequest;
@property (retain, nonatomic) NSURLConnection *urlConnection;
@property (weak, nonatomic) NSString *streamName;

- (void) publishStream;




@end
