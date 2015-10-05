//
//  CustomCameraViewController.m
//  ActorsCam
//
//  Created by Ranosys on 25/08/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "CustomCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "PreviewView.h"
#import "ImagePreviewViewController.h"
#import "UIView+Toast.h"

#import <ImageIO/ImageIO.h>
#import <MediaPlayer/MediaPlayer.h>
#import "DashboardViewController.h"

// The amount of bits per pixel, in this case we are doing RGBA so 4 byte = 32 bits
#define BITS_PER_PIXEL 32
// The amount of bits per component, in this it is the same as the bitsPerPixel divided by 4 because each component (such as Red) is only 8 bits
#define BITS_PER_COMPONENT (BITS_PER_PIXEL/4)
// The amount of bytes per pixel, in this case a pixel is made up of Red, Green, Blue and Alpha so it will be 4
#define BYTES_PER_PIXEL (BITS_PER_PIXEL/BITS_PER_COMPONENT)

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

@interface CustomCameraViewController ()<AVCaptureFileOutputRecordingDelegate>{
    unsigned long long imageSize;
    NSString *navTitle;
    NSTimer *myTimer,*luminosityTimer;
    BOOL invalidateChecker, shouldCapture;
}

@property (nonatomic, retain) AVCaptureVideoPreviewLayer *prevLayer;

@property (nonatomic, weak) IBOutlet PreviewView *previewView;

@property (weak, nonatomic) IBOutlet UILabel *checkLightEffect;
@property (nonatomic, weak) IBOutlet UIButton *revertButton;
@property (nonatomic, weak) IBOutlet UIButton *captureButton;
@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;
@property (weak, nonatomic) IBOutlet UILabel *imageCount;
@property (weak, nonatomic) IBOutlet UIButton *doneOutlet;

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

@implementation CustomCameraViewController
@synthesize imageArray;

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
    navTitle = @"Take Photos";
//    _checkLightEffect.hidden = NO;
    _checkLightEffect.layer.borderColor = [UIColor colorWithRed:255.0/255.0 green:62.0/255.0 blue:37.0/255.0 alpha:1.0].CGColor;
    _checkLightEffect.layer.borderWidth = 2.0;
    _checkLightEffect.layer.cornerRadius = 10;
    _checkLightEffect.layer.masksToBounds = YES;
    
    [_doneOutlet changeTextLanguage:@"DONE"];
    [navTitle changeTextLanguage:navTitle];
    [_doneOutlet changeTextLanguage:@"DONE"];

//    imageArray = [NSMutableArray new];
//    imageSize = 0;
//    _imageCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)imageArray.count];
    
    // Create the AVCaptureSession
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [self setSession:session];
//    _previewView.translatesAutoresizingMaskIntoConstraints = YES;
//    self.previewView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);

    self.prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    _prevLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-78-64);
    
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
        
        AVCaptureDevice *videoDevice = [CustomCameraViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (error)
        {
            NSLog(@"%@", error);
        }
        
        if ([session canAddInput:videoDeviceInput])
        {
            [session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
            
        }
        
        AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
//        [audioDevice sete]
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
        if ([session canAddOutput:movieFileOutput])
        {
            [session addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if ([connection isVideoStabilizationSupported])
                [connection setPreferredVideoStabilizationMode:YES];
//                [connection setEnablesVideoStabilizationWhenAvailable:YES];
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
    invalidateChecker = YES;
    
    self.navigationController.navigationBarHidden = NO;
    CGRect framing = CGRectMake(0, 0, 30, 30);
    UIButton *button = [[UIButton alloc] initWithFrame:framing];
    [button setBackgroundImage:[UIImage imageNamed:@"SwitchCamera"] forState:UIControlStateNormal];
    UIBarButtonItem *barButton =[[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(revertCameraMethod:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = barButton;
    
    self.captureButton.selected = NO;
    
    self.title = navTitle;
    
//    imageSize = 0;
//    imageArray = nil;
    shouldCapture = true;
    imageArray = [NSMutableArray new];
    imageSize = 0;
    _imageCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)imageArray.count];
    self.imagePreview.image = nil;
//    _imageCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)imageArray.count];
//    for (int i=0; i<imageArray.count; i++) {
//        UIImage *yourImage = [imageArray objectAtIndex:i];
//        NSData *imgData = UIImageJPEGRepresentation(yourImage, 1.0f);
//        imageSize = imgData.length + imageSize;
//        NSLog(@"%llu",(unsigned long long)imgData.length);
//    }
//     NSLog(@"image size %llu",imageSize/1024/1024);

    dispatch_async([self sessionQueue], ^{
        [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
        [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
        [self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        
        __weak CustomCameraViewController *weakSelf = self;
        [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
            CustomCameraViewController *strongSelf = weakSelf;
            dispatch_async([strongSelf sessionQueue], ^{
                // Manually restarting the session since it must have been stopped due to an error.
                [[strongSelf session] startRunning];
            });
        }]];
        [[self session] startRunning];
        
    });
//    invalidateChecker = NO;
//    luminosityTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
//                                               target:self
//                                             selector:@selector(stillImageOutputView)
//                                             userInfo:nil
//                                              repeats:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
//    invalidateChecker = YES;
//    [luminosityTimer invalidate];
//    luminosityTimer = nil;
    [myTimer invalidate];
    myTimer = nil;

}

-(void)didReceiveMemoryWarning{
//    _stillImageOutput = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
//    [myTimer invalidate];
//    myTimer = nil;
    
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

//Action for rescaling image to avoid memory pressure
-(UIImage *)imageWithImage:(UIImage *)image1 scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image1 drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)stillImageOutputView{

//    MPVolumeView* volumeView = [[MPVolumeView alloc] init];
//    //find the volumeSlider
//    UISlider* volumeViewSlider = nil;
//    for (UIView *view in [volumeView subviews]){
//        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
//            volumeViewSlider = (UISlider*)view;
//            break;
//        }
//    }
//    [volumeView hideToastActivity];
//    [volumeViewSlider setValue:0.0f animated:NO];
//    [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];

    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
//            AVCaptureConnection* audioConnection ;//= [fileOutput connectionWithMediaType:AVMediaTypeAudio];
//    //        [audioConnection audioChannels.vo]
//    //        [videoConnection audioChannels.volumeView];
//            AVCaptureAudioChannel *a;
//    //        AVCaptureAudioChannel.vo
//            if(audioConnection)
//            {
//                for(AVCaptureAudioChannel* audioChannel in [audioConnection audioChannels])
//                {
//                    audioChannel.volume = 0.5;
//                }
//            }

//    videoConnection.audioChannel.v
//    _stillImageOutput.conn.
//    _stillImageOutput.
//    videoConnection.a
      if (!invalidateChecker) {
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                   completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *__strong error) {
                                                       CFDictionaryRef exifAttachments = CMGetAttachment( imageDataSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                                                       if (!invalidateChecker) {
                                                           if (exifAttachments)
                                                           {
                                                               // Do something with the attachments.
                                                               NSLog(@"attachements: %@", exifAttachments);
                                                           }
                                                           else
                                                               NSLog(@"no attachments");
                                                           
                                                           
                                                           NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                           UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                           CGSize scale;
                                                           scale.height=image.size.height/2;
                                                           scale.width=image.size.width/2;
                                                           image = [self imageWithImage:image scaledToSize:scale];
                                                           unsigned char* pixels = [self rgbaPixels:image];
                                                           double totalLuminance = 0.0;
                                                           for(int p=0;p<image.size.width*image.size.height;p+=4) {
                                                               totalLuminance += pixels[p]*0.299 + pixels[p+1]*0.587 + pixels[p+2]*0.114;
                                                           }
                                                           totalLuminance /= (image.size.width*image.size.height);
                                                           totalLuminance /= 255.0;
                                                           _checkLightEffect.text = [NSString stringWithFormat:@"%f",totalLuminance];
                                                           NSLog(@"Image.png = %f",totalLuminance);
                                                           
                                                           //                                                       videoConnection.enabled = NO;
                                                           //                                                       image = [self screenshot];
                                                           //
                                                           //                                                       scale.height=image.size.height/2;
                                                           //                                                       scale.width=image.size.width/2;
                                                           //                                                       image = [self imageWithImage:image scaledToSize:scale];
                                                           //                                                       pixels = [self rgbaPixels:image];
                                                           //                                                       totalLuminance = 0.0;
                                                           //                                                       for(int p=0;p<image.size.width*image.size.height;p+=4) {
                                                           //                                                           totalLuminance += pixels[p]*0.299 + pixels[p+1]*0.587 + pixels[p+2]*0.114;
                                                           //                                                       }
                                                           //                                                       totalLuminance /= (image.size.width*image.size.height);
                                                           //                                                       totalLuminance /= 255.0;
                                                           //                                                       _checkLightEffect.text = [NSString stringWithFormat:@"%f",totalLuminance];
                                                           //                                                       NSLog(@"Image.png = %f",totalLuminance);
                                                       }
                                                   }];
      }
}

//- (UIImage*)screenshot
//{
//    // Create a graphics context with the target size
//    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
//    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
//    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
//    if (NULL != &UIGraphicsBeginImageContextWithOptions)
//        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
//    else
//        UIGraphicsBeginImageContext(imageSize);
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    // Iterate over every window from back to front
//    for (UIWindow *window in [[UIApplication sharedApplication] windows])
//    {
//        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
//        {
//            // -renderInContext: renders in the coordinate space of the layer,
//            // so we must first apply the layer's geometry to the graphics context
//            CGContextSaveGState(context);
//            // Center the context around the window's anchor point
//            CGContextTranslateCTM(context, [window center].x, [window center].y);
//            // Apply the window's transform about the anchor point
//            CGContextConcatCTM(context, [self.previewView transform]);
//            // Offset by the portion of the bounds left of and above the anchor point
//            CGContextTranslateCTM(context,
//                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
//                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
//            
//            // Render the layer hierarchy to the current context
//            [[self.previewView layer] renderInContext:context];
//            
//            // Restore the context
//            CGContextRestoreGState(context);
//        }
//    }
//    
//    // Retrieve the screenshot image
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
//    
//    return image;
//}
//
//- (UIImage *)captureView:(UIView *)view {
//    CGRect screenRect = self.prevLayer.frame;
//    
//    UIGraphicsBeginImageContext(screenRect.size);
//    
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    [[UIColor blackColor] set];
//    CGContextFillRect(ctx, screenRect);
//    
//    [view.layer renderInContext:ctx];
//    
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
//    
//    return newImage;
//}

-(unsigned char*) rgbaPixels:(UIImage*)image
{
    
    // Define the colour space (in this case it's gray)
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    
    // Find out the number of bytes per row (it's just the width times the number of bytes per pixel)
    size_t bytesPerRow = image.size.width * BYTES_PER_PIXEL;
    // Allocate the appropriate amount of memory to hold the bitmap context
    unsigned char* bitmapData = (unsigned char*) malloc(bytesPerRow*image.size.height);
    
    // Create the bitmap context, we set the alpha to none here to tell the bitmap we don't care about alpha values
    CGContextRef context = CGBitmapContextCreate(bitmapData,image.size.width,image.size.height,BITS_PER_COMPONENT,bytesPerRow,colourSpace,kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
    
    // We are done with the colour space now so no point in keeping it around
    CGColorSpaceRelease(colourSpace);
    
    // Create a CGRect to define the amount of pixels we want
    CGRect rect = CGRectMake(0.0,0.0,image.size.width,image.size.height);
    // Draw the bitmap context using the rectangle we just created as a bounds and the Core Graphics Image as the image source
    CGContextDrawImage(context,rect,image.CGImage);
    // Obtain the pixel data from the bitmap context
    unsigned char* pixelData = (unsigned char*)CGBitmapContextGetData(context);
    
    // Release the bitmap context because we are done using it
    CGContextRelease(context);
    return pixelData;
#undef BITS_PER_PIXEL
#undef BITS_PER_COMPONENT
}

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
    else if (context == SessionRunningAndDeviceAuthorizedContext)
    {
        BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRunning)
            {
                [[self revertButton] setEnabled:YES];
                //                [[self recordButton] setEnabled:YES];
                [[self captureButton] setEnabled:YES];
            }
            else
            {
                [[self revertButton] setEnabled:NO];
                //                [[self recordButton] setEnabled:NO];
                [[self captureButton] setEnabled:NO];
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
    [[self revertButton] setEnabled:NO];
    //    [[self recordButton] setEnabled:NO];
    [[self captureButton] setEnabled:NO];
    invalidateChecker = YES;
//    [luminosityTimer invalidate];
//    luminosityTimer = nil;
    [myTimer invalidate];
    myTimer = nil;
    
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
        
        AVCaptureDevice *videoDevice = [CustomCameraViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
        
        [[self session] beginConfiguration];
        
        [[self session] removeInput:[self videoDeviceInput]];
        if ([[self session] canAddInput:videoDeviceInput])
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
            
            [CustomCameraViewController setFlashMode:AVCaptureFlashModeOff forDevice:videoDevice];
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
            [[self revertButton] setEnabled:YES];
            //            [[self recordButton] setEnabled:YES];
            [[self captureButton] setEnabled:YES];
//            invalidateChecker = NO;
//            luminosityTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
//                                                               target:self
//                                                             selector:@selector(stillImageOutputView)
//                                                             userInfo:nil
//                                                              repeats:YES];
            
            myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(stillImageOutputView)
                                                     userInfo:nil
                                                      repeats:YES];
            
        });
    });
}
#pragma mark - end

#pragma mark - Capture Image Method
- (IBAction)captureImageMethod:(id)sender
{
    if ((imageSize > 20*1024*1024) || !shouldCapture) {
        //set toast
//        invalidateChecker = YES;
//        [myTimer invalidate];
//        myTimer = nil;
//        [luminosityTimer invalidate];
//        luminosityTimer = nil;
       [self.view makeToast:@"File size cannot exceed 20 MB."];
    }
    else{
    self.captureButton.selected = YES;
//        invalidateChecker = YES;
        [myTimer invalidate];
        myTimer = nil;
//        [luminosityTimer invalidate];
//        luminosityTimer = nil;
        
    dispatch_async([self sessionQueue], ^{
        // Update the orientation on the still image output video connection before capturing.
        [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
        
        // Flash set to Auto for Still Capture
        [CustomCameraViewController setFlashMode:AVCaptureFlashModeOff forDevice:[[self videoDeviceInput] device]];
        
        // Capture a still image.
        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
            if (imageDataSampleBuffer)
            {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
//                NSLog(@"%llu",(unsigned long long)imageData.length);
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                NSData *imgData1 = UIImageJPEGRepresentation(image, 1.0f);
                imageSize = imgData1.length + imageSize;
                NSLog(@"%llu",(unsigned long long)imgData1.length);
                 NSLog(@"%llu",(unsigned long long)imageData.length);
                unsigned long long tempSize = imageSize + imgData1.length;
                 NSLog(@"%llu",(unsigned long long)imgData1.length);
                if (tempSize > 20*1024*1024) {
                    //set toast
                    shouldCapture = false;
                   [self.view makeToast:@"File size cannot exceed 20 MB."];
                }
                else{
                    [imageArray addObject:image];
                   imageSize = imageSize + imgData1.length;
                    _imagePreview.image = image;
                    int count = [_imageCount.text intValue];
                    count = count+1;
                    _imageCount.text = [NSString stringWithFormat:@"%d", count];
//                    invalidateChecker = NO;
//                    luminosityTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
//                                                                       target:self
//                                                                     selector:@selector(stillImageOutputView)
//                                                                     userInfo:nil
//                                                                      repeats:YES];
                    myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                               target:self
                                                             selector:@selector(stillImageOutputView)
                                                             userInfo:nil
                                                              repeats:YES];
                }
                
//                [[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
            }
        }];
    });
    }
}
#pragma mark - end

#pragma mark - focusAndExposeTap gesture action
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

#pragma mark File Output Delegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    if (error)
        NSLog(@"%@", error);
    
    [self setLockInterfaceRotation:NO];
    
    // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
    UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
    [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
    
    [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error)
            NSLog(@"%@", error);
        
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
        
        if (backgroundRecordingID != UIBackgroundTaskInvalid)
            [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
    }];
}
#pragma mark - end

#pragma mark - Device Configuration
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
    if ([self captureButton].isSelected) {
        self.captureButton.selected = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[[self previewView] layer] setOpacity:0.0];
            
            [UIView animateWithDuration:.25 animations:^{
                [[[self previewView] layer] setOpacity:1.0];
            }];
        });
    }
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

#pragma mark - Done Action
- (IBAction)doneMethod:(UIButton *)sender {
//    [imageArray addObject:[UIImage imageNamed:@"0.png"]];
//    [imageArray addObject:[UIImage imageNamed:@"modal2.jpeg"]];
//    [imageArray addObject:[UIImage imageNamed:@"modal3.jpeg"]];
//    [imageArray addObject:[UIImage imageNamed:@"modal4.jpeg"]];
//    [imageArray addObject:[UIImage imageNamed:@"modal5.jpeg"]];
//    [imageArray addObject:[UIImage imageNamed:@"modal6.jpeg"]];
//    [imageArray addObject:[UIImage imageNamed:@"modal7.jpeg"]];
//    [imageArray addObject:[UIImage imageNamed:@"modal8.jpeg"]];
    
    if (imageArray.count==0) {
        for (id controller in [self.navigationController viewControllers])
        {
            if ([controller isKindOfClass:[DashboardViewController class]])
            {
                [self.navigationController popToViewController:controller animated:YES];
                break;
            }
        }

//        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ImagePreviewViewController *previewView =[storyboard instantiateViewControllerWithIdentifier:@"ImagePreviewViewController"];
        previewView.imageArray = [imageArray mutableCopy];
        previewView.customCameraVC = self;
        [self.navigationController pushViewController:previewView animated:YES];
    }
}
#pragma mark - end

#pragma mark - Preview image action
- (IBAction)previewImageButton:(UIButton *)sender {
    if (imageArray.count==0) {
//        sender.enabled = NO;
    }
    else{
//        sender.enabled = YES;
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ImagePreviewViewController *previewView =[storyboard instantiateViewControllerWithIdentifier:@"ImagePreviewViewController"];
        previewView.imageArray = [imageArray mutableCopy];
        previewView.customCameraVC = self;
        [self.navigationController pushViewController:previewView animated:YES];
    }
}
#pragma mark - end
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
