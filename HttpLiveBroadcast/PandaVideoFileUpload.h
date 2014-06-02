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

@interface PandaVideoFileUpload : NSObject 


@property (retain, nonatomic) NSURL *fileUrl;
@property (retain, nonatomic) NSURL *apiUrl;
@property (retain, nonatomic) NSMutableURLRequest *urlRequest;
@property (retain, nonatomic) NSURLConnection *urlConnection;
@property (retain, atomic) ASIFormDataRequest *request;
+(NSString*) getFileName:(NSURL*)fileUrl;


-(void) uploadFile;



@end
