//
//  PandaVideoLib.h
//  HttpLiveBroadcast
//
//  Created by Leon Gordin on 5/25/14.
//  Copyright (c) 2014 Panda OS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVCaptureSession.h"
#import "AVFoundation/AVCaptureOutput.h"
#import "AVFoundation/AVCaptureDevice.h"
#import "AVFoundation/AVCaptureInput.h"
#import "AVFoundation/AVCaptureVideoPreviewLayer.h"
#import "AVFoundation/AVMediaFormat.h"
#import "AVFoundation/AVAssetWriter.h"
#import "AVFoundation/AVAssetWriterInput.h"
#import "AVFoundation/AVError.h"

#import "AVFoundation/AVVideoSettings.h"

#import "PandaVideoFileUpload.h"
#import "PandaVideoLivePublish.h"

@protocol PandaVideoLibDelegate

- (void) captureReady;

- (void) setProgress:(float)progress;

@end

@interface PandaVideoLib : NSObject <AVCaptureFileOutputRecordingDelegate, PandaVideoFileUploadDelegate, PandaVideoLivePublishDelegate>

+(int) chunkSize;

+(PandaVideoLib*)getInstance;

@property (retain, nonatomic) NSString *captureQuality;

@property (retain, atomic) AVCaptureSession *captureSession;
@property (retain, atomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (retain, atomic) AVCaptureMovieFileOutput *fileOutput;
@property (retain, atomic) AVCaptureInput *videoInput;
@property (retain, nonatomic) id<PandaVideoLibDelegate> delegate;
@property (retain, atomic) NSTimer * fileUploadTimer;
@property (retain, atomic) NSMutableArray *uploadQueue;
@property (retain, atomic) PandaVideoFileUpload *fileUpload;
@property (retain, atomic) PandaVideoLivePublish *livePublish;

@property (weak, nonatomic) NSString *entryId;
@property (weak, nonatomic) NSString *apiUrl;
@property (weak,nonatomic) NSString *streamName;


@property (atomic) BOOL recording;
@property (retain, atomic) AVCaptureDevice *currentCamera;
@property (nonatomic) AVCaptureVideoOrientation videoOrientation;

- (AVCaptureVideoPreviewLayer *) getPreviewLayer;
- (AVCaptureSession *) getCaptureSession;
- (void) initCaptureSession;
- (void) initStream;
- (AVCaptureSession *) startRecordingSession;
- (void) endRecordingSession;
- (void) embedIntoView:(UIView *)targetView;
- (void) flipCamera;




@end
