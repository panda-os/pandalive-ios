//
//  PandaVideoLib.m
//  HttpLiveBroadcast
//
//  Created by Leon Gordin on 5/25/14.
//  Copyright (c) 2014 Panda OS. All rights reserved.
//

#import "PandaVideoLib.h"

@implementation PandaVideoLib

+ (int) chunkSize {
    static int chunkSize;
    return chunkSize;
}

static PandaVideoLib *instance =nil;

+(PandaVideoLib *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            NSLog(@"Initializing PandaVideoLib Instance");
            instance= [PandaVideoLib new];
            [instance initCaptureSession];
            instance.fileUpload = [[PandaVideoFileUpload alloc] init];
            instance.livePublish = [[PandaVideoLivePublish alloc] init];
            [instance.fileUpload setDelegate:instance];
            [instance.fileUpload setProgressDelegate:instance];

            [instance.livePublish setDelegate:instance];

        }
    }
    return instance;
}

@synthesize apiUrl;
@synthesize streamName;

- (AVCaptureVideoPreviewLayer *) getPreviewLayer {
    return self.previewLayer;
}


- (AVCaptureSession *) getCaptureSession {
    return self.captureSession;
}

- (void) initCaptureSession {
    // init capture session
    self.captureSession = [[AVCaptureSession alloc] init];
    
    // set default quality
//    self.captureQuality = AVCaptureSessionPresetMedium;
    self.captureQuality = AVCaptureSessionPresetMedium;

    
    // begin configuration
    [self.captureSession beginConfiguration];

    self.captureSession.sessionPreset = self.captureQuality;

    // init audio capture device
    AVCaptureDevice *videoCaptureDevice = [self frontCamera];
    self.currentCamera = videoCaptureDevice;
    
    // set autofocus
    if([self.currentCamera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
    {
        if ( [self.currentCamera lockForConfiguration:NULL] == YES ) {
            [self.currentCamera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            [self.currentCamera unlockForConfiguration];
        }
    }
    
    
    NSError *error = nil;
    AVCaptureDeviceInput *videoCaptureInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
    
    AVCaptureDevice *audioCaptureDevice = [self iphoneMicrophone];
    AVCaptureDeviceInput *audioCaptureInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
    
    
    
    [self.captureSession addInput:videoCaptureInput];
    [self.captureSession addInput:audioCaptureInput];
    
    self.videoInput = videoCaptureInput;
    

    
    // init preview layer
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    
    // setup orientation listener
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    // detect and set to current orientation
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(setVideoOrientation)
                                   userInfo:nil
                                    repeats:NO];


    self.fileOutput = [self attachFileWriter:self.captureSession];

    
    
    [self.captureSession commitConfiguration];
    
    [self.captureSession startRunning];
    
    

    
}





- (AVCaptureSession *) startRecordingSession {

    
    // start recording to file
    NSURL *outputUrl = [self getOutputFileUrl];
    [self.fileOutput startRecordingToOutputFileURL:outputUrl recordingDelegate:self];
    
    
    // set recording flag
    self.recording = YES;
    
    return self.captureSession;
}

- (void) endRecordingSession {
    
    // unset recording flag
    self.recording = NO;

    
    [self.fileOutput stopRecording];
    [self.fileUpload stopUpload];
    [self.fileUploadTimer invalidate];
}




/**
 *
 *
 **/
- (NSURL *) getOutputFileUrl {
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    // NSTimeInterval is defined as double
    NSNumber *timeStampObj = [NSNumber numberWithDouble: timeStamp];
    NSString *fileName = [[NSString stringWithFormat:@"livestream-%@.mp4",timeStampObj] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //@TODO: Save in caches path
    NSString *documentsDirPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSURL *documentsDirUrl = [NSURL fileURLWithPath:documentsDirPath isDirectory:YES];
    NSURL *url = [NSURL URLWithString:fileName relativeToURL:documentsDirUrl];
    
    return [url absoluteURL];
}

// delete a file by name from Documents folder
- (void) deleteFile:(NSString *)fileName {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        NSLog(@"Successfuly removed file: %@ ",filePath);
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }

}



- (void) flipCamera {
    NSError *error = nil;
    // begin configuration of capture session
    [self.captureSession beginConfiguration];
    
    AVCaptureDevice *newCamera = nil;
    
    if([self.currentCamera position] == AVCaptureDevicePositionFront)
    {
        newCamera = [self backCamera];
    }
    else
    {
        newCamera = [self frontCamera];

    }

    // set autofocus
    if([newCamera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
    {
        if ( [newCamera lockForConfiguration:NULL] == YES ) {
            [newCamera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            [newCamera unlockForConfiguration];
        }
    }
    
    
    self.captureSession.sessionPreset = self.captureQuality;


    // remove current input and add new input instead
    AVCaptureDeviceInput *videoCaptureInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:&error];
    [self.captureSession removeInput:self.videoInput];
    [self.captureSession addInput:videoCaptureInput];
    self.videoInput = videoCaptureInput;
    
    [self setFileWriterOrientation:self.fileOutput];
    
    // commit configuration of capture session
    [self.captureSession commitConfiguration];
    
    self.currentCamera = newCamera;
}


- (void) embedIntoView:(UIView *)targetView {
    NSLog(@"Embedding into %@", targetView);
    [self.previewLayer removeFromSuperlayer];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    self.previewLayer.frame = targetView.bounds;
    
    [targetView.layer addSublayer:self.previewLayer];
    
}

#pragma mark - callbacks for file writing

- (void) captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections
{
    NSLog(@"Starting write to file at %@",[PandaVideoFileUpload getFileName:outputFileURL]);
    
}


// callback when output file stops writing
- (void) captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    // switch output file to new file
    NSLog(@"Stopped writing to file at %@", [PandaVideoFileUpload getFileName:outputFileURL]);
    
    // if file stopped because we reached maximum chunk duration, switch to new output file
    if(error.code == AVErrorMaximumDurationReached)
    {
        [self switchOutputFile];
        
        [self uploadSingleFile:outputFileURL];
    }
    else
    {
        NSLog(@"Error code: %ld", (long) error.code);
        NSLog(@"Error description: %@", error.description);
    }
}


- (void) cleanupDocumentsDir
{
    NSLog(@"Cleaning up documents directory");
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *documentsDirPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSError *error = nil;
    for (NSString *path in [fm contentsOfDirectoryAtPath:documentsDirPath error:&error]) {
        NSString *fullPath = [documentsDirPath stringByAppendingPathComponent:path];
        BOOL success = [fm removeItemAtPath:fullPath error:&error];
        
        if (!success || error) {
            NSLog(@"Failed to delete file %@ in directory %@", path, documentsDirPath);
        }
    }
}


#pragma mark - private methods

                                              
- (AVCaptureDevice *)iphoneMicrophone {
    NSLog(@"Detecting audio devices");
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    for (AVCaptureDevice *device in devices) {
        NSLog(@"Using audio capture device: %@", device.localizedName);
        return device;
        
    }
    return nil;
}

 - (AVCaptureDevice *)frontCamera {
     NSLog(@"Detecting video devices");
     NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
     for (AVCaptureDevice *device in devices) {
         if ([device position] == AVCaptureDevicePositionFront) {
             NSLog(@"video capture device: %@", device.localizedName);
             return device;
         }
     }
     return nil;
 }
 

- (AVCaptureDevice *)backCamera {
    NSLog(@"Detecting video devices");
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionBack) {
            NSLog(@"video capture device: %@", device.localizedName);
            return device;
        }
    }
    return nil;
}


// method that switches the output file
- (void) switchOutputFile {
    NSURL *outputUrl = [self getOutputFileUrl];
    NSLog(@"Switching to: %@", outputUrl);
    
    // begin configuration
    [self.captureSession beginConfiguration];
    // remove the current writer
    [self.captureSession removeOutput:self.fileOutput];
    
    // attach new writer
    self.fileOutput = [self attachFileWriter:self.captureSession];
    // commit configuration
    [self.captureSession commitConfiguration];

    [self.fileOutput startRecordingToOutputFileURL:outputUrl recordingDelegate:self];
    
    
}


- (AVCaptureMovieFileOutput *) attachFileWriter:(AVCaptureSession *)captureSession {
    NSLog(@"Attaching file writer");
    AVCaptureMovieFileOutput *fileOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    // set fragment interval to 5 seconds
    [fileOutput setMovieFragmentInterval:CMTimeMakeWithSeconds(5, 1)];
    [fileOutput setMaxRecordedDuration:CMTimeMakeWithSeconds(5,1)];
    
    [self.captureSession addOutput:fileOutput];
    
    [self setFileWriterOrientation:fileOutput];
    
    return fileOutput;
}


/** 
 *for flipping of video
 **/
- (void) setFileWriterOrientation:(AVCaptureMovieFileOutput*)fileOutput {
   
    for ( AVCaptureConnection *connection in [fileOutput connections] )
    {
        for ( AVCaptureInputPort *port in [connection inputPorts] )
        {
            if ( [[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                [connection setVideoOrientation:self.videoOrientation];
               // NSLog(@"orientation -  %d", self.videoOrientation);
            }
        }
    }
    
    
    
}



#pragma mark - initiate stream


- (void) initStream
{
    [self cleanupDocumentsDir];
    
    [self.livePublish setApiUrl:[NSURL URLWithString:self.apiUrl]];
    [self.livePublish setStreamName:self.streamName];
    
    [self.livePublish publishStream];
    
}

#pragma mark - init stream callbacks

- (void) streamPublished:(ASIHTTPRequest*)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    
    // check which request was finished
    NSLog(@"Request finished: Response %@", responseString);
    
    // parse the json
    NSData *jsonData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error=nil;

    NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    NSDictionary *entry = [parsedData objectForKey:@"entry"];
    self.fileUpload.entryId = [entry objectForKey:@"id"];
    

    // call capture ready
    [self.delegate captureReady];
    
}


#pragma mark - file upload callback


- (void) uploadSingleFile:(NSURL*)fileUrl
{
    [self.fileUpload setApiUrl:[NSURL URLWithString:self.apiUrl]];
    
    NSLog(@"Uploading file %@ to url: %@ via POST", [PandaVideoFileUpload getFileName:fileUrl], apiUrl );
    [self.fileUpload uploadFile:fileUrl];
    
    
    
}

- (void) uploadFiles:(NSTimer*)timer
{
    NSLog(@"Upload files timer fired");
    
    
    
}


#pragma mark - PandaVideoFileUploadDelegate callback to handle deletion of file

- (void) uploadFinished:(ASIFormDataRequest*)request
{
    NSDictionary *userInfo = [request userInfo];
    NSString *fileName = [userInfo objectForKey:@"fileName"];
    
    NSLog(@"Trying to delete the file");
    [self deleteFile:fileName];
}

- (void) uploadFailed:(ASIFormDataRequest*)request
{
    NSDictionary *userInfo = [request userInfo];
    NSString *fileName = [userInfo objectForKey:@"fileName"];
    
    NSLog(@"Trying to delete the file");
    [self deleteFile:fileName];
}

#pragma mark - PandaVideoFileProgressDelegate callback to handle deletion of file

-(void)setProgress:(float)newProgress
{
    [self.delegate setProgress:newProgress];
}

#pragma mark - orientation change detection

- (void)orientationChanged:(NSNotification *)notification{
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(setVideoOrientation)
                                   userInfo:nil
                                    repeats:NO];
}


- (void) setVideoOrientation {
//    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    // only update orientation in case of not recording
    if(self.recording == NO) {
        AVCaptureVideoOrientation newOrientation = 0;
        switch (statusBarOrientation) {
            case UIInterfaceOrientationLandscapeLeft:
                newOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            case UIInterfaceOrientationLandscapeRight:
                newOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            default:
                break;
        }
        self.videoOrientation = newOrientation;

        [self setFileWriterOrientation:self.fileOutput];
        
        if(newOrientation)
        {
            if ([self.previewLayer respondsToSelector:@selector(connection)])
            {
                if ([self.previewLayer.connection isVideoOrientationSupported])
                {
                    [self.previewLayer.connection setVideoOrientation:newOrientation];
                }
            }
            else
            {
                // Deprecated in 6.0; here for backward compatibility
                if ([self.previewLayer isOrientationSupported])
                {
                    [self.previewLayer setOrientation:newOrientation];
                }                
            }
            
        }
        
    }
    
}


@end
