//
//  CustomVideoViewController.m
//  ActorsCam
//
//  Created by Ranosys on 02/10/15.
//  Copyright © 2015 Ranosys. All rights reserved.
//

#import "CustomVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "PreviewView.h"
#import "UIView+Toast.h"
#import "VideoPreviewViewController.h"
#import "DashboardViewController.h"

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

@interface CustomVideoViewController ()<AVCaptureFileOutputRecordingDelegate>{
    unsigned long long imageSize;
    NSString *navTitle;
    NSURL *videoFileUrl;
    NSTimer *myTimer;
    int second, minute, hour, continousSecond;
    BOOL disappearView;
    UIButton *revertButton;
}

@property (nonatomic, retain) AVCaptureVideoPreviewLayer *prevLayer;

@property (nonatomic, weak) IBOutlet PreviewView *previewView;

//@property (nonatomic, weak) IBOutlet UIButton *revertButton;
@property (weak, nonatomic) IBOutlet UIButton *doneOutlet;
@property (strong, nonatomic) IBOutlet UIButton *captureOutlet;

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer;

// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

// Utilities.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;

@end

@implementation CustomVideoViewController
@synthesize imageArray,captureOutlet;

- (BOOL)isSessionRunningAndDeviceAuthorized
{
    return [[self session] isRunning] && [self isDeviceAuthorized];
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
    return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}

#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
   
    navTitle = @"Record Video";
    
    [[self captureOutlet] setSelected:NO];
    //set image at capture button
    [captureOutlet setImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
    [captureOutlet setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateSelected];
    
    [navTitle changeTextLanguage:navTitle];
    
    imageArray = [NSMutableArray new];
    imageSize = 0;
    
    // Create the AVCaptureSession
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [self setSession:session];
    
    self.prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    self.prevLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-78-64);
    
    self.prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.previewView.layer addSublayer:self.prevLayer];
    
    [self checkDeviceAuthorizationStatus];
    
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
    
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue];
    
    dispatch_async(sessionQueue, ^{
        [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
        
        NSError *error = nil;
        
        AVCaptureDevice *videoDevice = [CustomVideoViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (error)
        {
            NSLog(@"%@", error);
        }
        
        if ([session canAddInput:videoDeviceInput])
        {
            [session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
            dispatch_async(dispatch_get_main_queue(), ^{
                // Why are we dispatching this to the main queue?
                // Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
                // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                
                [[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:AVCaptureVideoOrientationPortrait];
            });
        }
        
        AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
        AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        
        if (error)
        {
            NSLog(@"%@", error);
        }
        
        if ([session canAddInput:audioDeviceInput])
        {
            [session addInput:audioDeviceInput];
        }
        
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        movieFileOutput.maxRecordedFileSize = 1024 *1024 * 20;
        
        if ([session canAddOutput:movieFileOutput])
        {
            [session setSessionPreset: AVCaptureSessionPresetMedium];
            [session addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8) {
                if ([connection isVideoStabilizationSupported])
                    [connection setEnablesVideoStabilizationWhenAvailable:YES];
            } else {
                [connection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeAuto];
            }
            
            [self setMovieFileOutput:movieFileOutput];
        }
        
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([session canAddOutput:stillImageOutput])
        {
            [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
            [session addOutput:stillImageOutput];
            [self setStillImageOutput:stillImageOutput];
        }
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    self.navigationController.navigationBarHidden = NO;
    //right bar button of navigaion bar
    CGRect framing = CGRectMake(0, 0, 30, 30);
    revertButton = [[UIButton alloc] initWithFrame:framing];
    [revertButton setBackgroundImage:[UIImage imageNamed:@"SwitchCamera"] forState:UIControlStateNormal];
    UIBarButtonItem *barButton =[[UIBarButtonItem alloc] initWithCustomView:revertButton];
    [revertButton addTarget:self action:@selector(revertCameraMethod:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = barButton;
    
    disappearView = NO;
    videoFileUrl = nil;
    captureOutlet.selected = NO;
    
    self.title = navTitle;
    continousSecond = 0;
    _timeLabel.text = [NSString stringWithFormat:@"00:00:00"];
    [self removeVideoFile];
    
    if (imageArray.count == 0) {
        [_doneOutlet changeTextLanguage:@"CANCEL"];
    }
    else{
        [_doneOutlet changeTextLanguage:@"DONE"];
    }
    
    dispatch_async([self sessionQueue], ^{
        [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
        [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
        [self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        
        __weak CustomVideoViewController *weakSelf = self;
        [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
            CustomVideoViewController *strongSelf = weakSelf;
            dispatch_async([strongSelf sessionQueue], ^{
                // Manually restarting the session since it must have been stopped due to an error.
                [[strongSelf session] startRunning];
            });
        }]];
        [[self session] startRunning];
        
    });
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [myTimer invalidate];
    myTimer = nil;
    continousSecond = 0;
}

- (void)viewDidDisappear:(BOOL)animated
{
    
    dispatch_async([self sessionQueue], ^{
        [[self session] stopRunning];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
        
        [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
        [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
        [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
    });
}
#pragma mark - end

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == CapturingStillImageContext)
    {
        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
        
        if (isCapturingStillImage)
        {
            [self runStillImageCaptureAnimation];
        }
    }
    else if (context == RecordingContext)
    {
        BOOL isRecording = [change[NSKeyValueChangeNewKey] boolValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRecording)
            {
                [revertButton setEnabled:NO];
                [[self captureOutlet] setEnabled:YES];
            }
            else
            {
                [revertButton setEnabled:YES];
                [[self captureOutlet] setEnabled:YES];
            }
        });
    }
    else if (context == SessionRunningAndDeviceAuthorizedContext)
    {
        BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRunning)
            {
                [revertButton setEnabled:YES];
                [[self captureOutlet] setEnabled:YES];
            }
            else
            {
                [revertButton setEnabled:NO];
                [[self captureOutlet] setEnabled:NO];
            }
        });
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Revert camera actions
- (IBAction)revertCameraMethod:(id)sender
{
    [revertButton setEnabled:NO];
    [[self captureOutlet] setEnabled:NO];
    [myTimer invalidate];
    myTimer = nil;
    continousSecond = 0;
    captureOutlet.selected = NO;
    
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
        AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
        AVCaptureDevicePosition currentPosition = [currentVideoDevice position];

        switch (currentPosition)
        {
            case AVCaptureDevicePositionUnspecified:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
            case AVCaptureDevicePositionBack:
                preferredPosition = AVCaptureDevicePositionFront;
                break;
            case AVCaptureDevicePositionFront:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
        }

        AVCaptureDevice *videoDevice = [CustomVideoViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];

        [[self session] beginConfiguration];

        [[self session] removeInput:[self videoDeviceInput]];
        if ([[self session] canAddInput:videoDeviceInput])
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];

            [CustomVideoViewController setFlashMode:AVCaptureFlashModeOff forDevice:videoDevice];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];

            [[self session] addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
        }
        else
        {
            [[self session] addInput:[self videoDeviceInput]];
        }

        [[self session] commitConfiguration];

        dispatch_async(dispatch_get_main_queue(), ^{
            [revertButton setEnabled:YES];
            [[self captureOutlet] setEnabled:YES];
        });
    });
}
#pragma mark - end

#pragma mark - Capture Image Method
- (IBAction)captureMethod:(id)sender
{
    [myTimer invalidate];
    myTimer = nil;
    
     [_doneOutlet changeTextLanguage:@"DONE"];
    if (captureOutlet.isSelected) {
        captureOutlet.selected = NO;
    }
    else{
        captureOutlet.selected = YES;
        continousSecond = 0;
        _timeLabel.text = [NSString stringWithFormat:@"00:00:00"];
        myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                   target:self
                                                 selector:@selector(targetMethod)
                                                 userInfo:nil
                                                  repeats:YES];
    }
    
        dispatch_async([self sessionQueue], ^{
            if (![[self movieFileOutput] isRecording])
            {
                [self setLockInterfaceRotation:YES];
               
                if ([[UIDevice currentDevice] isMultitaskingSupported])
                {
                    // Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until AVCam returns to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library when AVCam is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error: after the recorded file has been saved.
                    [self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil]];
                }
                
                // Update the orientation on the movie file output video connection before starting recording.
                [[[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:AVCaptureVideoOrientationPortrait];
                
                // Turning OFF flash for video recording
                [CustomVideoViewController setFlashMode:AVCaptureFlashModeOff forDevice:[[self videoDeviceInput] device]];
                
                // Start recording to a temporary file.
                
                NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                
                NSString *filePath = [documentsPath stringByAppendingPathComponent:@"movie.mov"];
               
                [[self movieFileOutput] startRecordingToOutputFileURL:[NSURL fileURLWithPath:filePath] recordingDelegate:self];
                
            }
            else
            {
                [[self movieFileOutput] stopRecording];
            }
        });
    
}
#pragma mark - end

-(void)targetMethod{
    continousSecond++;
    hour = (continousSecond / 3600)%24;
    minute = (continousSecond /60) % 60;
    second = (continousSecond  % 60);
    _timeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hour,minute,second];
}

#pragma mark - FocusAndExposeTap gesture action
- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
    CGPoint devicePoint = CGPointMake(.5, .5);
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}
#pragma mark - end

#pragma mark - File output delegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    //	if (error)
    //		NSLog(@"%@", error);
    captureOutlet.selected = NO;
    [myTimer invalidate];
    myTimer = nil;
    int sizeExceed;
    sizeExceed = 0;
    if (error) {
        NSLog(@"%@", error);
        NSLog(@"Caught Error");
        if ([error code] == AVErrorDiskFull) {
            NSLog(@"Caught disk full error");
            sizeExceed = 1;
        } else if ([error code] == AVErrorMaximumFileSizeReached) {
            sizeExceed = YES;
            NSLog(@"Caught max file size error");
            sizeExceed = 2;
        } else if ([error code] == AVErrorMaximumDurationReached) {
            NSLog(@"Caught max duration error");
        } else {
            NSLog(@"Caught other error");
        }
    }
    
    [self setLockInterfaceRotation:NO];
    
    // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
    UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
    [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
   // NSLog(@"%lld",_movieFileOutput.recordedFileSize);
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"movie.mov"];
     outputFileURL = [NSURL URLWithString:filePath];
    videoFileUrl = [NSURL URLWithString:filePath];
    
        if (backgroundRecordingID != UIBackgroundTaskInvalid)
            [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
    if (sizeExceed == 1) {
        [self.view makeToast:@"Your device storage is full."];
    }
    else if (sizeExceed == 2){
        [self.view makeToast:@"File size cannot exceed 20 MB."];
    }
//    }];
    if (disappearView) {
        if (videoFileUrl == nil) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            VideoPreviewViewController *videoPreviewView =[storyboard instantiateViewControllerWithIdentifier:@"VideoPreviewView"];
            videoPreviewView.filePath = videoFileUrl;
            [self.navigationController pushViewController:videoPreviewView animated:YES];
        }
    }
}

#pragma mark Device Configuration
- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *device = [[self videoDeviceInput] device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
            {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
            {
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    });
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    if ([device hasFlash] && [device isFlashModeSupported:flashMode])
    {
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    }
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}
#pragma mark - end

#pragma mark - UI
- (void)runStillImageCaptureAnimation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[self previewView] layer] setOpacity:0.0];
        [UIView animateWithDuration:.25 animations:^{
            [[[self previewView] layer] setOpacity:1.0];
        }];
    });
}

- (void)checkDeviceAuthorizationStatus
{
    NSString *mediaType = AVMediaTypeVideo;
    
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if (granted)
        {
            //Granted access to mediaType
            [self setDeviceAuthorized:YES];
        }
        else
        {
            //Not granted access to mediaType
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Alert"
                                            message:@"Your app doesn't have permission to use Camera, please change privacy settings"
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                [self setDeviceAuthorized:NO];
            });
        }
    }];
}
#pragma mark - end

#pragma mark - Done action
- (IBAction)doneMethod:(UIButton *)sender {
    
    if ([[self movieFileOutput] isRecording])
    {
        [myTimer invalidate];
        myTimer = nil;
        continousSecond = 0;
        disappearView = YES;
        [[self movieFileOutput] stopRecording];
    }
    else{
        if (videoFileUrl == nil) {
//            [self.navigationController popViewControllerAnimated:YES];
            
            for (id controller in [self.navigationController viewControllers])
            {
                if ([controller isKindOfClass:[DashboardViewController class]])
                {
                    [self.navigationController popToViewController:controller animated:YES];
                    break;
                }
            }
        }
        else{
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            VideoPreviewViewController *videoPreviewView =[storyboard instantiateViewControllerWithIdentifier:@"VideoPreviewView"];
            videoPreviewView.filePath = videoFileUrl;
            [self.navigationController pushViewController:videoPreviewView animated:YES];
        }

    }
   
}
#pragma mark - end

- (void)removeVideoFile
{
   
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"movie.mov"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (fileExists) {
        [fileManager removeItemAtPath:filePath error:nil];
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
