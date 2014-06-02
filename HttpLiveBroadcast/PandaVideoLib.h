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

@interface PandaVideoLib : NSObject <AVCaptureFileOutputRecordingDelegate>

+(int) chunkSize;

+(PandaVideoLib*)getInstance;


@property (retain, atomic) AVCaptureSession *captureSession;
@property (retain, atomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (retain, atomic) AVCaptureMovieFileOutput *fileOutput;
@property (retain, atomic) AVCaptureInput *videoInput;
@property (retain, atomic) AVAssetWriter *assetWriter;
@property (retain, nonatomic) id delegate;
@property (retain, atomic) NSTimer * fileUploadTimer;
@property (retain, atomic) NSMutableArray *uploadQueue;

@property (atomic) BOOL recording;
@property (retain, atomic) AVCaptureDevice *currentCamera;

- (AVCaptureVideoPreviewLayer *) getPreviewLayer;
- (AVCaptureSession *) getCaptureSession;
- (void) initCaptureSession;
- (AVCaptureSession *) startRecordingSession;
- (void) endRecordingSession;
- (void) embedIntoView:(UIView *)targetView;
- (void) flipCamera;





@end
