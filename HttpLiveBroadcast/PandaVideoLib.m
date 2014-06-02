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
            instance.uploadQueue = [[NSMutableArray alloc] init];
            
            
        }
    }
    return instance;
}

- (AVCaptureVideoPreviewLayer *) getPreviewLayer {
    return self.previewLayer;
}


- (AVCaptureSession *) getCaptureSession {
    return self.captureSession;
}

- (void) initCaptureSession {
    // init capture session
    self.captureSession = [[AVCaptureSession alloc] init];
    
    
    // begin configuration
    [self.captureSession beginConfiguration];

    
    // init audio capture device
    AVCaptureDevice *videoCaptureDevice = [self frontCamera];
    self.currentCamera = videoCaptureDevice;
    
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
    
    [self.assetWriter startWriting];
    
    // set recording flag
    self.recording = YES;
    
//    self.fileUploadTimer = [NSTimer scheduledTimerWithTimeInterval:5
//                                     target:self
//                                   selector:@selector(uploadFiles:)
//                                   userInfo:nil
//                                    repeats:YES];
    
    
    return self.captureSession;
}

- (void) endRecordingSession {
    
    // unset recording flag
    self.recording = NO;

    
    [self.fileOutput stopRecording];
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
    NSString *fileName = [NSString stringWithFormat:@"leon-%@.mp4",timeStampObj];
    
    NSString *documentsDirPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSURL *documentsDirUrl = [NSURL fileURLWithPath:documentsDirPath isDirectory:YES];
    NSURL *url = [NSURL URLWithString:fileName relativeToURL:documentsDirUrl];
    
    return [url absoluteURL];
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
    
    // remove current input and add new input instead
    AVCaptureDeviceInput *videoCaptureInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:&error];
    [self.captureSession removeInput:self.videoInput];
    [self.captureSession addInput:videoCaptureInput];
    self.videoInput = videoCaptureInput;
    
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
    
    // set fragment interval to 10 seconds
    [fileOutput setMovieFragmentInterval:CMTimeMakeWithSeconds(5, 1)];
    [fileOutput setMaxRecordedDuration:CMTimeMakeWithSeconds(5,1)];
    
    [self.captureSession addOutput:fileOutput];
    
    
    return fileOutput;
}


#pragma mark - file upload callback


- (void) uploadSingleFile:(NSURL*)fileUrl
{
    NSString *apiUrl = @"http://10.0.0.125:8080/pvp/pvpserver/public/live";
    PandaVideoFileUpload *fileUpload = [[PandaVideoFileUpload alloc] init];
    [fileUpload setFileUrl:fileUrl];
    [fileUpload setApiUrl:[NSURL URLWithString:apiUrl]];
    
    NSLog(@"Uploading file %@ to url: %@ via POST", [PandaVideoFileUpload getFileName:fileUrl], apiUrl );
    [fileUpload uploadFile];
    [self.uploadQueue addObject:fileUpload];
    
    
    
}

- (void) uploadFiles:(NSTimer*)timer
{
    NSLog(@"Upload files timer fired");
    
    
    
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
